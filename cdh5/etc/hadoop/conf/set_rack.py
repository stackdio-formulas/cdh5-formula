#!/usr/bin/python
import sys
import boto3

sys.argv.pop(0)

client = boto3.client("ec2")

for ip in sys.argv:
	response = client.describe_instances(
	DryRun=True,
	Filters=[
		{
			'Name': 'private-ip-address',
			'Values': [
				ip,
			]
		},
	])

	is_spot = False

	if response:
		lifecycle = response["Reservations"][0]["Instances"][0]["InstanceLifecycle"]
		if lifecycle == "spot":
			is_spot = True
			print "/spot-rack"

	if not is_spot:
		print "/default_rack"