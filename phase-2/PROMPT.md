Given:
- The web app has a health URL that returns JSON
- The web app runs in Kubernetes
- The web app is exposed via a NodePort service

Requirements:
- A CronJob checks whether the service is up and running

Restrictions:
- Use only official images for the CronJob
- The CronJob image should be as minimal as possible
- The health URL response must be parsed as JSON in the CronJob
