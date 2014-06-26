include:
  - cdh5.repo

pig:
  pkg:
    - installed
    - pkgs:
      - pig
    - require:
      - module: cdh5_refresh_db

