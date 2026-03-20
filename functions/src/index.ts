import {setGlobalOptions} from "firebase-functions";
import * as logger from "firebase-functions/logger";
import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {getAuth} from "firebase-admin/auth";
import {onDocumentDeleted} from "firebase-functions/v2/firestore";
import {beforeUserCreated} from "firebase-functions/v2/identity";

import {setup} from "./setup";
import {onUserCreating} from "./users";

const region = "asia-northeast2";
setGlobalOptions({maxInstances: 10});

initializeApp();
const db = getFirestore();
const auth = getAuth();

exports.onServiceVersionDeleted = onDocumentDeleted(
  {region, document: "service/version"},
  (event) => setup({logger, db, auth}, event),
);

exports.handleBeforeUserCreated = beforeUserCreated(
  {region},
  (event) => onUserCreating({logger, db, auth}, event),
);
