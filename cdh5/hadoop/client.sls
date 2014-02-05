include:
  - cdh5.repo

hadoop-client: 
  pkg:
    - installed
    - require:
      - module: cdh5_refresh_db

