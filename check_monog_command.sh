---
- name: Check and execute MongoDB query
  hosts: all
  tasks:
    - name: Check if mongo is installed
      command: which mongo
      register: mongo_check
      ignore_errors: yes

    - name: Check if mongosh is installed
      command: which mongosh
      register: mongosh_check
      ignore_errors: yes

    - name: Decide which tool to use
      set_fact:
        mongo_tool: >-
          {{
            'mongo' if mongo_check.rc == 0 else
            ('mongosh' if mongosh_check.rc == 0 else 'none')
          }}

    - name: Fail if no MongoDB tools are installed
      fail:
        msg: "Neither mongo nor mongosh is installed on the target machine."
      when: mongo_tool == 'none'

    - name: Run MongoDB query using mongo
      command: "{{ mongo_tool }} b --eval 'db.a.find().forEach(printjson)'"
      register: mongo_query_result
      when: mongo_tool != 'none'

    - name: Print the query output
      debug:
        msg: >
          MongoDB query output:
          {{ mongo_query_result.stdout if mongo_query_result.rc == 0 else 'Failed to run query: ' ~ mongo_query_result.stderr }}
