import requests
import zipfile
import os
import shutil
import tempfile
import time
from dotenv import load_dotenv

load_dotenv()
MAX_RETRIES = int(os.getenv("MAX_RETRIES", 5))

GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
REPO_OWNER = os.getenv("REPO_OWNER")
REPO_NAME = os.getenv("REPO_NAME")


def get_last_run():
    url = f'https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/actions/runs'
    headers = {
        'Authorization': f'token {GITHUB_TOKEN}',
        'Accept': 'application/vnd.github.v3+json'
    }
    response = requests.get(url, headers=headers)
    if response.status_code != 200:
        print(f"Error fetching runs: {response.status_code}")
        return None, None, None

    runs = response.json().get('workflow_runs', [])
    if not runs:
        print("No workflow runs found.")
        return None, None, None

    last_run = runs[0]
    run_id = last_run['id']
    status = last_run['status']
    conclusion = last_run['conclusion']

    print(f"Last run ID: {run_id}, Status: {status}, Conclusion: {conclusion}")
    return run_id, status, conclusion


def wait_for_completion():
    retries = 0
    while retries < MAX_RETRIES:
        run_id, status, conclusion = get_last_run()

        if not run_id:
            print("No runs to analyze.")
            return None, None

        if status in ["queued", "in_progress"]:
            print(f"Run is still {status}. Retrying in 60 seconds... ({retries + 1}/{MAX_RETRIES})")
            time.sleep(60)
            retries += 1
        else:
            return run_id, conclusion

    print("Max retries reached. Exiting.")
    return None, None


def get_failure_details(run_id):
    url = f'https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/actions/runs/{run_id}/jobs'
    headers = {
        'Authorization': f'token {GITHUB_TOKEN}',
        'Accept': 'application/vnd.github.v3+json'
    }
    response = requests.get(url, headers=headers)
    if response.status_code != 200:
        print(f"Error fetching failure details: {response.status_code}")
        return [], {}

    failed_steps = []
    job_step_mapping = {}
    jobs = response.json().get('jobs', [])
    for job in jobs:
        if job['conclusion'] == 'failure':
            print(f"Failed Job: {job['name']}")
            job_step_mapping[job['name']] = {step['name']: step for step in job.get('steps', [])}
            for step in job.get('steps', []):
                if step['conclusion'] == 'failure':
                    print(f"Failed Step: {step['name']}, Status: {step['status']}")
                    failed_steps.append((job['name'], step['name']))
    return failed_steps, job_step_mapping


def download_logs(run_id):
    url = f'https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/actions/runs/{run_id}/logs'
    headers = {
        'Authorization': f'token {GITHUB_TOKEN}',
        'Accept': 'application/vnd.github+json'
    }
    response = requests.get(url, headers=headers)
    if response.status_code != 200:
        print(f"Error fetching logs for run {run_id}: {response.status_code}")
        return None

    temp_file = tempfile.NamedTemporaryFile(delete=False, suffix='.zip')
    with open(temp_file.name, 'wb') as f:
        f.write(response.content)
    print(f"Logs downloaded to: {temp_file.name}")
    return temp_file.name


def extract_failed_logs(log_file, failed_steps):
    if not log_file or not os.path.exists(log_file):
        print("No log file available to extract.")
        return "No logs available."

    extract_dir = tempfile.mkdtemp()
    failure_details = []

    try:
        with zipfile.ZipFile(log_file, 'r') as zip_ref:
            zip_ref.extractall(extract_dir)

        for job_name, step_name in failed_steps:
            log_file_name = None
            for file in os.listdir(extract_dir):
                if job_name.lower().replace(" ", "-") in file.lower() and file.endswith('.txt'):
                    log_file_name = file
                    break

            if not log_file_name:
                failure_details.append(
                    f"=== Log for Failed Step: {step_name} ===\nNo log file found for job: {job_name}")
                continue

            file_path = os.path.join(extract_dir, log_file_name)
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.readlines()

                step_logs = []
                capturing = False
                for i, line in enumerate(content):
                    if "##[group]Run" in line:
                        capturing = True
                        start_idx = max(0, i - 5)  # Add context before the step
                        step_logs.extend([line.strip() for line in content[start_idx:i]])

                    if capturing:
                        step_logs.append(line.strip())
                        if "##[error]" in line or "exit code" in line:
                            end_idx = min(len(content), i + 5)  # Add context after failure
                            step_logs.extend([line.strip() for line in content[i + 1:end_idx]])
                            break
                        elif "##[endgroup]" in line and "Run" not in line:
                            capturing = False

                if step_logs:
                    filtered_logs = []
                    for log in step_logs:
                        if ("Branch name" in log or
                                "##[error]" in log or
                                "exit code" in log or
                                "##[group]Run" in log or
                                "shell:" in log):  # Include command setup
                            filtered_logs.append(log)
                    if filtered_logs:
                        failure_details.append(f"=== Log for Failed Step: {step_name} ===\n" + "\n".join(filtered_logs))
                    else:
                        failure_details.append(f"=== Log for Failed Step: {step_name} ===\n" + "\n".join(step_logs))
                else:
                    failure_details.append(
                        f"=== Log for Failed Step: {step_name} ===\nStep-specific logs not found. Full job log:\n{'-' * 50}\n" + "\n".join(
                            [line.strip() for line in content]))

        shutil.rmtree(extract_dir)
        os.remove(log_file)

        if failure_details:
            return "\n\n".join(failure_details)
        return "No detailed logs found for failed steps."

    except zipfile.BadZipFile as e:
        return f"Failed to extract logs: {str(e)}"


def analyze_last_run():
    run_id, conclusion = wait_for_completion()

    if not run_id:
        print("No runs to analyze.")
        return {"status": "unknown", "details": "No run found."}

    if conclusion != "failure":
        print("Last run did not fail. No further analysis needed.")
        return {"status": "completed", "details": f"Run completed with conclusion: {conclusion}"}

    print("\nFetching failure details...")
    failed_steps, _ = get_failure_details(run_id)
    if not failed_steps:
        return {"status": "failed", "details": "No failed steps found, but the run failed."}

    print("\nDownloading logs...")
    log_file = download_logs(run_id)
    if not log_file:
        return {"status": "failed", "details": "Failed to download logs."}

    print("\nExtracting and analyzing logs...")
    failure_details = extract_failed_logs(log_file, failed_steps)

    return {"status": "failed", "details": failure_details}


if __name__ == "__main__":
    result = analyze_last_run()
    print("\n=== Final Result ===")
    print(result)