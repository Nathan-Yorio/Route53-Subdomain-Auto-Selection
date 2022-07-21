import boto3
from boto3.session import Session
import pyinputplus as pyip #version 0.2.12
import colorama
from colorama import Fore, Back, Style
from colorama import init
init()

from mod import get_load_balancers

# Store the acquired load balancers in an index
lbs = get_load_balancers.app_load_balancers()

#print(colors.bg.green, "SKk", colors.fg.red, "Amartya")
#print(colors.bg.lightgrey, "SKk", colors.fg.red, "Amartya")
# Make the index into an input menu
print(Fore.CYAN)
print("Choose a load balancer")
print(Fore.RESET)
chosen_lb = pyip.inputMenu(lbs, lettered=False, numbered=True)

# Non-service calls easy way to get a non-exhaustive list of region names from the local session
# courtesy of https://stackoverflow.com/questions/38451032/how-to-list-available-regions-with-boto3-python
boto3_session = Session()
ec2_regions = boto3_session.get_available_regions('ec2')
print(Fore.CYAN)
print("Choose an AWS Region")
print(Fore.RESET)
chosen_region = pyip.inputMenu(ec2_regions, lettered=False, numbered=True)


# Get the chosen domain name as input from the user
print(Fore.CYAN)
print("Input a chosen pre-existing higher order domain name, IE: example.com ")
print(Fore.RESET)
domain_name    =  pyip.inputStr('Domain name> ') 
print(Fore.CYAN)
print("Choose a subdomain name")
print(Fore.RESET)
print("IE: If you want [something].example.com")
print("Only type: something")
print("This is because the terraform script just adds something + example.com")
print("to equal something.example.com")
print(Fore.RED)
#don't let them type a . even though you just told them not to, just in case
subdomain_name =  pyip.inputStr('Subdomain name> ') 
print(Fore.RESET)

# Store the chosen input as the variables in tfvars as 
# load_balancer_name = "chosen_lb"

# tfvars_file = open('default.tfvars', 'w') #Write mode for single line
tfvars_file = open('default.tfvars', 'a') #append mode to add line to EOF

print(Fore.RESET)
print("Writing Load Balancer Name Variable to EOF....\n")
tfvars_file.writelines('\n'+'load_balancer_name     = '+'\"'+chosen_lb+'\"')
print("Writing Domain Name Variable to EOF\n")
tfvars_file.writelines('\n'+'route53_domain_name    = '+'\"'+domain_name+'\"')
print("Writing Subdomain Name Variable to EOF\n")
tfvars_file.writelines('\n'+'route53_subdomain_name = '+'\"'+subdomain_name+'\"')
print("Writing Region ID Variable to EOF\n")
tfvars_file.writelines('\n'+'region_id = '+'\"'+chosen_region+'\"')

# closing the file
tfvars_file.close()

print(Fore.GREEN)
print("Chosen LB written to default.tfvars")
print("Chosen Domain Name written to default.tfvars")
print("Chosen Subdomain Name written to default.tfvars")
print("Chosen Region ID written to default.tfvars")

#Finds how many lines there are in the text file
""" one = 1
while one:
    file_line = tfvars_file.readline()
    if not file_line:
        print("EOF is....", file_line)
        one = zero """