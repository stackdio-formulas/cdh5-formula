#!/usr/bin/python
import sys
import boto3

region = "us-east-1"

sys.argv.pop(0)

client = boto3.client("ec2", region)

for ip in sys.argv:
	response = client.describe_instances(
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
		lifecycle = response["Reservations"][0]["Instances"][0].get("InstanceLifecycle")
		if lifecycle == "spot":
			is_spot = True
			print "/spot-rack"

	if not is_spot:
		print "/default_rack"