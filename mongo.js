// The 'db' object is a Drizzle database client that is used to interact with the database.
// This is used to avoid writing raw SQL queries in a JavaScript/TypeScript environment.
// https://orm.drizzle.team/docs/overview

import { drizzle } from 'drizzle-orm/neon-http';
import { neon } from '@neondatabase/serverless';
import * as schema from './schema';
import { POSTGRES_URL } from '$lib/config';

const postgres_db = drizzle(neon(POSTGRES_URL), { schema });

// User is viewing client detail page and wishes to view all reports
// Client ID is already known to us from the front-end
// Query Postgres for all completed reports to render and list on the page
const postgres_reports = await postgres_db.query.factReportRequests.findMany({
	with: { dimItems: true },
	where: {
		eq(dimItems.clientId, clientId),
		eq(factReportRequests.status, 'Completed'),
	}
});

// User clicks on the rendered link which references the report_id from fact_report_requests
// Query MongoDB for the report
// The 'mongo_db' object is a MongoDB database
import { MongoClient } from 'mongodb';
import { MONGO_URL } from '$lib/config';

const client = new MongoClient(MONGO_URL);
const mongo_db = client.db('database');
const mongo_reports = mongo_db.collection('reports');

const query = [
  { $match: { "report.asset_report_id": PLAID_REPORT_ID } },
  { $unwind: "$report.items" },
  { $unwind: "$report.items.accounts" },
  { $match: { "report.items.accounts.account_id": "7keRPVDrEWSlKRadebnwSJrk9Db49vtdAank6" } },
  { $project: { transactions: "$report.items.accounts.transactions", _id: 0 } }
];

const result = await mongo_reports.aggregate(query).toArray();
