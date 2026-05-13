# Montague Project Overview

## What this project is

Montague is a field operations platform for a construction business.

Its job is to keep the company’s daily work in one system:
- plan jobs and tasks
- assign crews
- record what happened in the field
- review labor hours
- track equipment
- manage maintenance issues

In simple terms, it connects office planning with field execution.

## Why it matters

Today, this kind of work is often split across spreadsheets, texts, calls, and separate tools.

Montague is meant to give the business:
- one clear source of operational truth
- better labor visibility
- better equipment visibility
- cleaner handoff from field to office
- stronger accountability and audit history

## Core business flow

### 1. Define the work
The office creates jobs and breaks them into smaller work items.

### 2. Build the crew plan
Employees are grouped into crews. A foreman can be assigned to each crew.

### 3. Schedule the work
A crew is assigned to a job, and optionally to a specific work item, for a specific date.

### 4. Execute in the field
The foreman opens the daily report for that assignment and records:
- who worked
- how many hours they worked
- what work was done
- notes and photos
- any equipment issues

### 5. Review labor
The office reviews the resulting time entries and makes corrections if needed.

### 6. Track equipment movement
Assets can be assigned, moved, and marked in transit or unavailable.

### 7. Handle exceptions
If equipment has a problem, a maintenance work order is created and tracked to completion.

### 8. Keep an audit trail
Important actions are logged so the business can see what changed, when, and by whom.

## Core data entities

### Tenant
The company account.

Why it exists:
- keeps one company’s data separate from another

### User
A person with app access.

Examples:
- admin
- operations manager
- foreman
- payroll reviewer

Why it exists:
- users log in and perform actions in the system

### Employee
A worker or staff member as an operational person record.

Why it exists:
- not everyone who works needs a login
- labor history should remain even if access changes

### Job
A top-level piece of company work.

Why it exists:
- jobs are the main business container for planning, labor, and equipment use

### Work Item
A smaller unit of work under a job.

Why it exists:
- lets the business track labor and progress at a more useful level than just the job
- supports standard work and change-order work in one model

### Crew
A reusable labor group.

Why it exists:
- field work is commonly scheduled by crew, not just by individual person

### Crew Member
A record showing which employee belongs to which crew and when.

Why it exists:
- crew membership changes over time
- history matters

### Assignment
A scheduled commitment for one crew to work on one job on one date.

Why it exists:
- connects planning to field execution

### Daily Report
The foreman’s record of what actually happened for an assignment.

Why it exists:
- captures real field activity, notes, photos, and exceptions

### Time Entry
A normalized labor record created from the daily report.

Why it exists:
- labor review needs structured rows, not just a submitted form

### Asset
A tracked piece of equipment or vehicle.

Why it exists:
- the business needs to know what equipment exists, where it is, and whether it is available

### Asset Move
A request or completed movement of an asset.

Why it exists:
- equipment movement is a workflow, not just a field update

### Maintenance Work Order
A tracked equipment issue.

Why it exists:
- maintenance needs assignment, priority, and status, not just notes

### File
An attachment such as a photo or document.

Why it exists:
- supports proof, context, and field documentation

### Audit Event
A record of an important action.

Why it exists:
- gives accountability and traceability

## Parent-child relationships

### Tenant is the parent of everything
Why:
- every record belongs to one company
- this is the top data boundary

### Employee can be the parent of User
Why:
- a person can exist as a worker before or without getting app access
- this keeps labor identity separate from login identity

### Job is the parent of Work Items
Why:
- work items are smaller parts of one job

### Crew is the parent of Crew Members
Why:
- a crew is made up of employees

### Job and Crew are parents of Assignments
Why:
- an assignment exists only when a specific crew is scheduled to a specific job

### Work Item can also be a parent of Assignment
Why:
- some assignments are tied to a specific task, not just the job in general

### Assignment is the parent of Daily Reports
Why:
- the daily report is the execution record for planned work

### Daily Report is the parent of Time Entries
Why:
- labor rows come from what the foreman submitted in the field

### Asset is the parent of Asset Moves
Why:
- moves are events in the life of one piece of equipment

### Asset is the parent of Maintenance Work Orders
Why:
- maintenance belongs to a specific asset

### Daily Report can also be a parent of Maintenance Work Orders
Why:
- a field report may be the source of the problem being reported

### User is the parent of key actions
Why:
- the system must know who created, submitted, requested, or changed something

### Files attach to Daily Reports, Asset Moves, and Maintenance Work Orders
Why:
- photos and documents need to stay linked to the business record they support

## In one sentence

Montague is a construction operations system that links planned work, field reporting, labor tracking, equipment movement, and maintenance into one business workflow.