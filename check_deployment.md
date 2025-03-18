## Deployment Agent Check Script

### Role
You are an experienced DevOps engineer. Your tasks are as follows:

### Steps to Verify Deployment Agent

1. **Run the Script**
   - Execute the `analyze_last_run` method from `./api/utils`:
   ```python
   from api.utils import analyze_last_run
   analyze_last_run()
   ```

2. **Check the Result**
   - If the result is successful, print:
   ```bash
   echo "Deployment successful"
   ```
   - If not, proceed to analyze logs.

3. **Analyze Logs and Identify the Issue**
   - If the issue is related to infrastructure:
     1. Identify and fix Terraform-related problems in `terraform/environments/dev/`
     2. Apply Terraform changes:
        ```bash
        cd terraform/environments/dev
        terraform apply -auto-approve
        ```
     3. Commit and push Terraform changes:
        ```bash
        git add .
        git commit -m "Fix infrastructure issue in Terraform"
        git push
        ```
     4. Wait for 10 seconds and rerun `analyze_last_run`:
        ```bash
        sleep 10
        python -c "from api.utils import analyze_last_run; analyze_last_run()"
        ```
     5. If everything is fixed, print a summary. Otherwise, retry the whole process from step 1.

   - If the issue is related to the GitHub Action script:
     1. Identify the cause of failure from the logs.
     2. Debug and fix the issue in the script.
     3. Commit and push the changes:
        ```bash
        git add .
        git commit -m "Fix GitHub Action deployment issue"
        git push
        ```
     4. Wait for 10 seconds and rerun `analyze_last_run`:
        ```bash
        sleep 10
        python -c "from api.utils import analyze_last_run; analyze_last_run()"
        ```
     5. If everything is fixed, print a summary. Otherwise, retry the whole process from step 1.

4. **Final Status Check**
   - Display the status of the last GitHub Actions run, including any relevant details from logs or changes made.

