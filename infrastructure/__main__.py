from strongmind_deployment.rails import RailsComponent
from strongmind_deployment.dynamo import DynamoComponent

table1 = DynamoComponent("properties", attributes={"id": "N"}, hash_key="id")
table2 = DynamoComponent("flags", attributes={"name": "S", "on": "B"}, hash_key="name", range_key="on")

pattern = "[LETTER, DATE, LEVEL, SEP, N, I, HAVE, WAITING_JOBS, JOBS, FOR, WAITING_WORKERS, " \
                       "WAITING=waiting, WORKERS=workers]"

component = RailsComponent("rails", dynamo_tables=[table1, table2],
                           md5_hash_db_password=True,
                           need_worker=True,
                           worker_log_metric_filters=[
                                {
                                    "pattern": pattern,
                                    "metric_transformation": {
                                        "name": "waiting_workers",
                                        "namespace": "Jobs",
                                        "value": "$WAITING_WORKERS",
                                    }
                                },
                               {
                                   "pattern": pattern,
                                   "metric_transformation": {
                                       "name": "waiting_jobs",
                                       "namespace": "Jobs",
                                       "value": "$WAITING_JOBS",
                                   }
                               }
                            ],
                           execution_entry_point=["sh", "-c", "echo 'hello world'"],
                           web_entry_point=["sh", "-c", "rails assets:precompile && rails server -b 0.0.0.0"])

