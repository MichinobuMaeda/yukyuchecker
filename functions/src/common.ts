import * as logger from "firebase-functions/logger";
import {Firestore} from "firebase-admin/firestore";
import {Auth} from "firebase-admin/auth";

export interface Context {
  logger: typeof logger;
  db: Firestore;
  auth: Auth;
}
