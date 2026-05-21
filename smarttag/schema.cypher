
// Neo4j Schema with Cleaned Indexes and Constraints

// Node Labels and Properties
/*
(:Ticket {
    ticket_id: string,                // JIRA ticket key (PROJECT-123)
    title: string,                    // Ticket title/summary
    description: string,              // Detailed ticket description
    created: datetime,                // Creation timestamp
    updated: datetime,                // Last update timestamp
    embedding: float[]                // Vector embedding of ticket content
                                      // Calculated using Xenova/all-MiniLM-L6-v2 model
                                      // Represents semantic meaning of ticket content
                                      // Dimensions: 384 (default for MiniLM-L6-v2)
                                      // Normalized to unit length for cosine similarity calculations
})

(:TagAssignment {
    ticket_id: string,                 // Reference to ticket
    tag_name: string,                  // Reference to tag
    timeframe_id: string,              // Reference to timeframe
    semantical_weight: float,          // AI-driven relevance score
    ticket_tag_aggregated_weight: float,          // Combined weight calculation
    ndb_ticket_tag_aggregated_weight: float,      // Notion Database specific weight
    reasoning: string,                 // Explanation for tag assignment
    created_at: datetime               // When tag was assigned
})

(:Tag {
    name: string                       // Tag name
})

(:Person {
    name: string,                      // Person's display name
    email: string                      // Unique email address
})

(:Status {
    name: string                       // Status name (e.g., "Open", "In Progress")
})

(:Priority {
    name: string                       // Priority level (e.g., "High", "Medium")
})

// Jira project
(:Project {
    id: string,                        // JIRA project key
    name: string,                      // Project name
    client_identifier: string          // Client reference
})

(:IndexSnapshot {
    client_indexing_process_id: integer,
    client_identifier: string,
    timestamp: datetime
})

(:IssueType {
    name: string                       // Bug, Feature, Epic, etc.
})

(:TimeFrame {
    year: integer,
    month: integer,
    week: integer,                     // Week number (1-53)
    yearWeek: string                   // Year-week string (e.g., "2023-W42")
})

// Project relationships
(Project)<-[:BELONGS_TO]-(Ticket)-[:APPEARS_IN]->(IndexSnapshot)-[:OCCURRED_IN]->(TimeFrame)

// Ticket-related relationships
(ticket:Ticket)-[:HAS_ASSIGNMENT]->(tagAssignment:TagAssignment)
(tagAssignment:TagAssignment)-[:FOR_TAG]->(tag:Tag)
(tagAssignment:TagAssignment)-[:ASSIGNED_IN]->(timeFrame:TimeFrame)

// Basic ticket relationships
(ticket:Ticket)-[:BELONGS_TO]->(project:Project)
(ticket:Ticket)-[:HAS_PRIORITY]->(priority:Priority)
(ticket:Ticket)-[:ASSIGNED_TO]->(person:Person)
(ticket:Ticket)-[:REPORTED_BY]->(person:Person)
(ticket:Ticket)-[:HAS_TYPE]->(issueType:IssueType)

// Status relationships with timestamps
(ticket:Ticket)-[:HAS_STATUS {
    timestamp: datetime              // When the ticket entered this status
}]->(status:Status)

// Tag statistical weights tracked over time
(tag:Tag)-[:APPEARS_IN_TIMEFRAME {
    statistical_weight: float,
    rarity_weight: float,
    frequency_weight: float,
    log_weight: float,
    ndb_log_weight: float,
    temporal_weight: float,
    last_used_at: datetime,
    first_used_at: datetime
}]->(timeFrame:TimeFrame)

// Connect IndexSnapshot to TimeFrame
(snapshot:IndexSnapshot)-[:OCCURRED_IN]->(timeFrame:TimeFrame)

// Hierarchical relationships
(ticket:Ticket)-[:PARENT_OF]->(subtask:Ticket)
(ticket:Ticket)-[:SUBTASK_OF]->(parent:Ticket)

// Snapshot relationships
(ticket:Ticket)-[:APPEARS_IN]->(snapshot:IndexSnapshot)
(tag:Tag)-[:APPEARS_IN]->(snapshot:IndexSnapshot)

// Time-based relationships for tickets
(ticket:Ticket)-[:CREATED_IN]->(timeFrame:TimeFrame)
(ticket:Ticket)-[:UPDATED_IN]->(timeFrame:TimeFrame)

// Other ticket relationships
(ticket1:Ticket)-[:RELATED_TO {
    similarity_score_ai: float,
    similarity_score_embeddings: float,
    relation_type: string,
    relation_reasoning: string
}]->(ticket2:Ticket)

# Comprehensive Neo4j Database Schema Description

## Database Overview
Our Neo4j graph database is a sophisticated system for tracking and analyzing tickets across different projects, with a focus on rich metadata, temporal tracking, and complex relationships.

## Node Types and Their Significance

### 1. Ticket Node
- Represents individual work items or issues
- **Key Properties**:
  - `ticket_id`: Unique identifier (e.g., "PROJECT-123")
  - `title`: Short description of the ticket
  - `description`: Detailed explanation
  - `created`: Original creation timestamp
  - `updated`: Last modification timestamp

### 2. TagAssignment Node
- Reifies the relationship between tickets and tags
- **Key Properties**:
  - `ticket_id`: Reference to the associated ticket
  - `tag_name`: Name of the associated tag
  - `timeframe_id`: Temporal context of the tag
  - `semantical_weight`: AI-calculated relevance score (0.0-1.0)
  - `ticket_tag_aggregated_weight`: Comprehensive tag significance: semantical_weight * 0.4 + log_weight * 0.4 + temporal_weight * 0.2
  - `ndb_ticket_tag_aggregated_weight`: Jira project specific weight: semantical_weight * 0.4 + ndb_log_weight * 0.4 + temporal_weight * 0.2
  - `reasoning`: Explanation for tag assignment
  - `created_at`: Timestamp of tag assignment

### 3. Tag Node
- Represents conceptual categories or characteristics
- **Key Properties**:
  - `name`: Unique tag identifier. Possible values:
    - code_cleanup
    - code_optimization
    - test_failure
    - client_program
    - azure_environment
    - file_sink
    - compaction_strategy
    - end_to_end
    - connector_kafka
    - exactly_once
    - documentation_update
    - time_interval
    - connector_hive
    - table_planner
    - sql_cast
    - state_changelog
    - state_restore
    - yarn_integration
    - docker_environment
    - savepoint_restore
    - dynamic_configuration
    - kubernetes_integration
    - restart_strategy
    - high_availability
    - failover_strategy
    - flink_ml
    - machine_learning
    - algorithm_kmeans
    - job_scheduling
    - state_management
    - format_csv
    - connector_filesystem
    - sql_integration
    - code_refactoring
    - async_sink
    - flink_connector
    - test_container
    - aws_services
    - localstack_integration
    - security_policy
    - flink_operator
    - windowing_function
    - event_time
    - sliding_window
    - checkpointing
    - connector_firehose
    - sink_committer
    - rat_plugin
    - build_tooling
    - developer_productivity
    - format_parquet
    - avro_format
    - api_compatibility
    - junit5_migration
    - rpc_module
    - configuration_management
    - sql_client
    - sql_parser
    - archunit_test
    - test_framework
    - state_rocksdb
    - adaptive_scheduler
    - rest_api
    - execution_graph
    - api_usability
    - zookeeper_integration
    - metric_naming
    - connector_elasticsearch
    - table_store
    - dependency_upgrade
    - local_recovery
    - task_management
    - ui
    - metrics
    - connector_mysql
    - connector_pulsar
    - api_deprecation
    - hadoop_integration
    - format_protobuf
    - connector_cassandra
    - watermark
    - kerberos_delegation
    - ui_interface
    - code_migration
    - pyflink
    - code_generation
    - connector_kinesis
    - watermarking
    - resource_management
    - connector_mongodb
    - connector_hbase
    - connector_postgres
    - none
    - connector_jdbc
    - connector_dynamodb
    - connector_oceanbase
    - state_migration
    - sql_optimization
    - ui_bug
    - sql_api
    - metric
    - data_quality
    - connector_kudu
    - sql_gateway
    - format_orc
    - format_json
    - connector_rabbitmq
    - memory_management
    - python_api
    - code_bug
    - connector_sqlserver
    - connector_prometheus
    - code_deprecation
    - connector_redshift
    - connector_sql
    - connector_oracle
    - format_avro
    - connector_aws
    - table_api
    - classloader_problem
    - blob_server
    - connector_datagen
    - connector_redis
    - connector_paimon
    - ui_information
    - watermark_strategy
    - type_extraction
    - code_compatibility
    - code_example
    - connector_snowflake
    - connector_pubsub
    - api_migration
    - scala_api
    - performance_ Bottleneck
    - streaming_mode
    - code_failure
    - connector_iceberg
    - class_loader
    - performance_bottleneck
    - connector_doris
    - release_testing
    - watermark_alignment
    - api_refactoring
    - mysql_cdc
    - data_loss
    - quickstart_project
    - dependency_removal
    - code_validation
    - data_lineage
    - data_migration
    - sql_bug
    - dependency_management
    - sql_functions
    - classloader_management
    - connector_starrocks
    - api_cleanup
    - connector_db2
    - connector_gcp
    - shuffle_service
    - connector_rocketmq
    - connector_tikv
    - sql_catalog
    - api_integration
    - code_integration
    - code_revert
    - hdfs_integration
    - java_api
    - elastic_scaling
    - security
    - history_server
    - custompartition
    - code_improvement
    - connector_s3
    - connector_debezium
    - code_quality
    - cep_library
    - enhancement
    - sql_failure
    - runtime
    - bug
    - code_removal
    - documentation
    - connector_cdc
    - release_management
    - network_management
    - performance_optimization
    - log4j_based
    - code_analysis
    - taskmanager
    - website
    - sql_ddl
    - pyflink_testing
    - github_actions
    - connector_clickhouse
    - application_mode
    - windows
    - connector_datadog
    - data_distribution
    - user_satisfaction
    - optimizer
    - compiler
    - cep_pattern
    - data_management
    - test_integration
    - sql_connector
    - format_raw
    - test_validation
    - cli_information
    - api_removal
    - command_line
    - sql_validation
    - code_enhancement
    - sql_query
    - backpressure
    - dependency_leak
    - connector_pinot
    - flink_mesos
    - connector_azure
    - connector_twitter
    - performance_testing
    - sql_feature
    - connector_pravega
    - taskexecutor
    - error_logging
    - api_bug
    - api_stability
    - documentation_generation
    - test_cleanup
    - code_backport
    - source
    - connector_influxdb
    - test_refactoring
    - code_style
    - join
    - gpu
    - code_realization
    - hash_partitioner
    - minicluster
    - sql_dialect
    - cluster_management
    - code_investigation
    - test_improvement
    - connector_socket
    - test_removal
    - connector_parquet
    - test_coverage
    - connector_hudi
    - connector_druid
    - error_handling
    - test_unstable
    - jvm_memory
    - code_decoupling
    - api_improvement
    - source_connector
    - test_optimization
    - community
    - api_enhancement
    - mesos_integration
    - ui_improvement
    - dependency_deprecation
    - test_data
    - api_optimization
    - batch_jobs
    - sql_cli
    - filesystem_integration
    - sql_compliance
    - batch
    - performance_regression
    - race_condition
    - code_duplication
    - state_backend
    - side_outputs
    - test_migration
    - api_validation
    - error_message
    - connector_couchbase
    - web_server
    - file_system
    - distributedcache
    - job_submission
    - log_management
    - statefun
    - serialization
    - akka_integration
    - flink_cli
    - stateful_functions
    - flink_benchmarks
    - api_update
    - test_environment
    - leader_election
    - object_reuse
    - ui_cleanup
    - exception
    - api_failure
    - sql_optimizer
    - sql_improvement
    - monitoring
    - sql_enhancement
    - side_output
    - code_review
    - connector_csv
    - sql_jars
    - cep_operator
    - jdbc_connector
    - datastream_api
    - timer
    - resource_leak
    - sql_sink
    - data_generation
    - dispatcher
    - queryable_state
    - scheduler
    - travis_environment
    - data_validation
    - ui_usability
    - documentation_removal
    - code_debugging
    - flink_runtime
    - filesystem
    - performance_debugging
    - connector_nifi
    - slot_management
    - code_leak
    - api_decoupling
    - ide_integration
    - code_regression
    - state_recovery
    - proxy_configuration
    - rescalingitcase
    - code_contribution
    - oome_permgen
    - javadoc
    - connector_improvement
    - jobmanager
    - documentation_cleanup
    - format_hadoop
    - ui_feature
    - http_function
    - code_management
    - standalone_mode
    - timer_service
    - code_simplification
    - test_configuration
    - dependency_migration
    - backpressure_stats
    - sdk
    - connector_akka
    - sql_planner
    - back_pressure
    - hive_integration
    - remote_environment
    - code_synchronization
    - connector_activemq
    - connector_integration
    - data_stream
    - data_duplication
    - api_design
    - akka_connector
    - connector_confluent
    - test_utils
    - code_usability
    - io_management
    - parameter_validation
    - ci_information
    - test_case
    - format_thrift
    - job_failure
    - documentation_bug
    - gelly
    - standalone_cluster
    - datastream
    - code_formatting
    - jvm_metrics
    - deadlock
    - code_fix
    - dependency_conflict
    - installation
    - code_inconsistency
    - file_cache
    - mini_cluster
    - flink_client

### 4. Person Node
- Represents individuals involved in ticket management
- **Key Properties**:
  - `name`: Display name
  - `email`: Unique identifier

### 5. Auxiliary Nodes
- **Status Node**: Ticket states. Possible values:
  - Resolved
  - In Progress
  - Open
  - Closed
  - Reopened
- **Priority Node**: Importance levels. Possible values:
  - Critical
  - Minor
  - Major
  - Blocker
  - Not a Priority
- **Project Node**: Organizational groupings. Possible values:
  - FLINK
- **IssueType Node**: Ticket categories. Possible values:
  - New Feature,
  - Improvement
  - Bug
  - Technical Debt
  - Sub-task
- **TimeFrame Node**: Temporal segmentation
  - `year`: Calendar year
  - `month`: Month of the year
  - `week`: Week number
  - `yearWeek`: Formatted identifier (e.g., "2024-W13")

## Relationship Types

### Ticket-Related Relationships
1. **Single Tag Assignment Flow**:
   - `(ticket:Ticket)-[:HAS_ASSIGNMENT]->(tagAssignment:TagAssignment)`
   - `(tagAssignment:TagAssignment)-[:FOR_TAG]->(tag:Tag)`
   - `(tagAssignment:TagAssignment)-[:ASSIGNED_IN]->(timeFrame:TimeFrame)`

2. **Ticket Context Relationships**:
   - `[:BELONGS_TO]`: Connects ticket to project
   - `[:HAS_PRIORITY]`: Links ticket to priority
   - `[:ASSIGNED_TO]`: Indicates ticket assignee
   - `[:REPORTED_BY]`: Shows ticket reporter
   - `[:HAS_TYPE]`: Connects ticket to issue type
   - `[:HAS_STATUS]`: Connects ticket to issue type holding timestamp indicating when the ticket entered this status

3. **Hierarchical Relationships**:
   - `[:PARENT_OF]`: Links parent ticket to subtasks
   - `[:SUBTASK_OF]`: Connects subtask to parent ticket

4. **Temporal Relationships**:
   - `[:CREATED_IN]`: Links ticket to creation timeframe
   - `[:UPDATED_IN]`: Links ticket to update timeframe

5. **Inter-Ticket Relationships**:
   - `[:RELATED_TO]`: Connects related tickets
     * `similarity_score`: Numerical measure of relationship strength
     * `relation_type`: Nature of the relationship
     * `reasoning`: Explanation of the connection
     * `similarity_score_ai`: Numerical measure of relationship assigned by LLM
     * `similarity_score_embeddings`: Numerical measure of relationship calculated using embeddings cosine similarity

### Tag Temporal Tracking
- `(tag:Tag)-[:APPEARS_IN_TIMEFRAME]`: Tracks tag statistical characteristics
  * `first_used_at`: Earliest tag usage
  * `last_used_at`: Most recent tag usage
  * `rarity_weight`: = Uniqueness measure,
  * `frequency_weight`: = Occurrence frequency = tagged_tickets_count / total_tickets_count,
  * `log_weight`: = LOG10(tagged_tickets_count + 1) / LOG10(max_count_of_tickets_per_tag + 1),
  * `ndb_log_weight`: = LOG10(tagged_tickets_count + 1) / LOG10(max_count_of_tickets_per_tag + 1),
  * `temporal_weight`: = Recency factor = (LOG(1 + (currentTimestamp - tag_last_used_at)) / LOG(1 + (7 * 365 * 24 * 60 * 60))),
  * `statistical_weight`: = Composite score = rarity_weight * 0.3 + frequency_weight * 0.3 + tag.temporal_weight * 0.4

### Temporal Weight Calculation
- Decay function based on time since last use
- Recent tags receive higher weights
- Prevents stale tags from dominating analysis

## Query Patterns and Use Cases
1. Team performance analysis
2. Tag evolution tracking
3. Ticket relationship exploration
4. Temporal trend identification
5. Cross-project insights generation

## Data Integrity Constraints
- Unique constraints on critical nodes
- Prevents duplicate entries
- Ensures data consistency across the graph

## Best Practices
- Maintain consistent tag naming
- Regularly review weight calculations
- Leverage temporal and semantic metadata
- Use relationship properties for nuanced analysis

## Sample Complex Query Template
```cypher
// Analyze team member work patterns with weighted tag analysis
MATCH (person:Person)<-[:ASSIGNED_TO]-(ticket:Ticket)-[:HAS_ASSIGNMENT]->(ta:TagAssignment)-[:FOR_TAG]->(tag:Tag)
WITH
    person,
    tag,
    COUNT(DISTINCT ticket) AS ticket_count,
    AVG(ta.ticket_tag_aggregated_weight) AS avg_tag_weight
RETURN
    person.name AS team_member,
    COLLECT({
        tag: tag.name,
        ticket_count: ticket_count,
        avg_tag_weight: avg_tag_weight
    })[0..5] AS top_work_areas
```
*/

// NODES - CONSTRAINTS (Only uniqueness constraints in Community Edition)
CREATE CONSTRAINT person_email IF NOT EXISTS
FOR (p:Person)
REQUIRE p.email IS UNIQUE;

CREATE CONSTRAINT project_id IF NOT EXISTS
FOR (p:Project)
REQUIRE p.id IS UNIQUE;

CREATE CONSTRAINT snapshot_id IF NOT EXISTS
FOR (s:IndexSnapshot)
REQUIRE s.client_indexing_process_id IS UNIQUE;

CREATE CONSTRAINT issue_type_name IF NOT EXISTS
FOR (i:IssueType)
REQUIRE i.name IS UNIQUE;

CREATE CONSTRAINT status_name IF NOT EXISTS
FOR (s:Status)
REQUIRE s.name IS UNIQUE;

CREATE CONSTRAINT priority_name IF NOT EXISTS
FOR (p:Priority)
REQUIRE p.name IS UNIQUE;

CREATE CONSTRAINT timeframe_unique IF NOT EXISTS
FOR (tf:TimeFrame)
REQUIRE (tf.year, tf.month, tf.week) IS UNIQUE;

CREATE CONSTRAINT tag_assignment_unique IF NOT EXISTS
FOR (ta:TagAssignment)
REQUIRE (ta.ticket_id, ta.tag_name, ta.timeframe_id) IS UNIQUE;

// NODE PROPERTY INDEXES
// Ticket indexes
CREATE INDEX ticket_id_idx IF NOT EXISTS FOR (t:Ticket) ON (t.ticket_id);
CREATE INDEX ticket_title_idx IF NOT EXISTS FOR (t:Ticket) ON (t.title);
CREATE INDEX ticket_created_idx IF NOT EXISTS FOR (t:Ticket) ON (t.created);
CREATE INDEX ticket_updated_idx IF NOT EXISTS FOR (t:Ticket) ON (t.updated);

// Person indexes
CREATE INDEX person_name_idx IF NOT EXISTS FOR (p:Person) ON (p.name);

// Tag index
CREATE INDEX tag_name_idx IF NOT EXISTS FOR (t:Tag) ON (t.name);

// Project indexes
CREATE INDEX project_name_idx IF NOT EXISTS FOR (p:Project) ON (p.name);
CREATE INDEX project_client_idx IF NOT EXISTS FOR (p:Project) ON (p.client_identifier);

// IndexSnapshot indexes
CREATE INDEX snapshot_timestamp_idx IF NOT EXISTS FOR (s:IndexSnapshot) ON (s.timestamp);

// TimeFrame indexes
CREATE INDEX timeframe_year_idx IF NOT EXISTS FOR (t:TimeFrame) ON (t.year);
CREATE INDEX timeframe_month_idx IF NOT EXISTS FOR (t:TimeFrame) ON (t.month);
CREATE INDEX timeframe_week_idx IF NOT EXISTS FOR (t:TimeFrame) ON (t.week);
CREATE INDEX timeframe_yearweek_idx IF NOT EXISTS FOR (t:TimeFrame) ON (t.yearWeek);

// TagAssignment indexes
CREATE INDEX tag_assignment_