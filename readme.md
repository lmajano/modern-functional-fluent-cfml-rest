# Modern Functional & Fluent CFML REST APIs

This repo is a demo for our presentation on building modern functional & fluent CFML REST APIs.

## App Setup

### Install Dependencies

Just use CommandBox and install them: `box install`

### Database setup

The database needed for this is MySQL 5.7+ or 8+. The SQL file for this project is located in the `/workbench/database` folder. Please use that to seed your database, and call the database fluentAPI for consistency with the `.env.example` file provided or you can use our migrations.

First create the database `fluentapi` in your MySQL database and get some credentials ready for storage:

```bash
# Seed your .env file with your db and credentials
dotenv populate

# reload the shell so the credentials are loaded
reload

# run our migrations
migrate up
```

### Start the app

Once you have your `.env`, your db loaded, and your `box.json` dependencies installed, you can start your server.

```bash
# Adobe
run-script start:adobe
run-script start:lucee
```

## What can you do in the app?

Apart from hitting the root of the site, which is an API echo response, there are lots of things you can do with this app

http://127.0.0.1:60146/

### Hit API Endpoints

- List rants: http://127.0.0.1:60146/api/v6/rants
- Create Rants
- Read Rants
- Update Rants
- Delete Rants

### View the Tests

http://127.0.0.1:60146/tests/runner.cfm

### View API Docs

http://127.0.0.1:60146/cbswagger

#### What can you do with the API Docs?

- Immport into Insomnia: https://insomnia.rest/
- Import into Postman: https://www.postman.com/
- Use with Swagger.io site: https://editor.swagger.io/

### View Route Visualizer

http://127.0.0.1:60146/route-visualizer

### View CBDebugger

http://127.0.0.1:60146/cbdebugger
