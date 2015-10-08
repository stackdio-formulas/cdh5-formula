##
# Standby NameNode SLS is a placeholder. The actual provisioning of
# the standby NN is handled in the regular hadoop.namenode SLS. This
# SLS is essentially a no-op so things don't break
##

# For some reason, newer versions of salt interpret and empty state as a failure, so we need something in here for it not to fail
dummy:
  cmd:
    - run
    - name: date
