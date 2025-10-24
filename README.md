# Bulk-Update-security
Leverage this script to update security permissions for configuration and Flexible asset

# API Key

You will need an API key and a CSV file with the template below to be able to run the script without any errors. You can grab the API by navigating to IT Glue > Admin > Settings > API Key.

CSV Template

<img width="658" height="121" alt="image" src="https://github.com/user-attachments/assets/ea6edfbf-5616-4c8b-8d6b-12b932bb1aa9" />

Resource Types can be:

1. configurations
2. flexible-assets
3. documents
4. passwords

Resource ID is the ID of the record you would like to update the permission.

This script supports up to 5 groups.

**You will need to update the Endpoint URL based on your instance region**

The base URL for all endpoints and methods is:

Partners with an account in the NA data center will use:
https://api.itglue.com

Partners with an account in the EU data center will use:
https://api.eu.itglue.com

Partners with an account in the Australia data center will use:
https://api.au.itglue.com
