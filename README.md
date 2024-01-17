
# WDMyCloudEX4100
perl program to check the free space of WDM and CloudEX4100 nas


Designed for use in Centreon 23.10

Install CPAN (if not installed):

bash
Copy code
sudo apt-get update
sudo apt-get install cpanminus
Instalar dependencias CPAN:

bash
Copy code
sudo cpanm Net::SNMP

This will install the Net::SNMP library and its dependencies.

Once you've installed these dependencies, you should be able to run your script 

Remember to give the file the necessary permissions

The check order to apply at Centreon would be as follows:

Define the command in Centreon:

Go to "Configuration" -> "Commands" -> "Checks" and click on "Add."

Command Name: Check_SNMP_WDMyCloudEX4100
Command Type: SNMP
Command Line: $USER1$/ex4100ns.pl $HOSTADDRESS$ $ARG1$ $ARG2$ $ARG3$ $ARG4$
This assumes that your script takes four arguments: host address, SNMP community, warning threshold, and critical threshold.

Define the service in Centreon:

Go to "Configuration" -> "Services" and click on "Add."

Service Description: Free_Space
Check Command: Check_SNMP_WDMyCloudEX4100
Host: (Select the host you want to monitor)
SNMP Community: public (or your SNMP community)
Argument 1: 192.168.1.x (or your host address)
Argument 2: comnidad (or your SNMP community)
Argument 3: 1000 (or your warning threshold)
Argument 4: 500 (or your critical threshold)
Adjust the parameters based on your script's requirements.

Apply Configuration:

Apply the configuration changes in Centreon.
