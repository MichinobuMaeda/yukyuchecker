import {DocumentSnapshot} from "firebase-admin/firestore";

import {Context} from "./common";

/**
 * Performs initial setup for version 1 of the service configuration.
 * @param {Context} context - The function context containing logger, db, and auth.
 * @param {DocumentSnapshot | undefined} data - The deleted version document snapshot.
 * @return {Promise<void>}
 */
async function setupV1(
  {logger, db, auth}: Context,
  data: DocumentSnapshot,
): Promise<void> {
  logger.info("Performing setup for version 1");

  const email = data.get("email") as string | undefined;

  if (!email) {
    logger.error("No admin email provided in the version document");
    return;
  }

  logger.info("Admin email provided:", email);
  const user = await auth.createUser({email});
  const batch = db.batch();
  batch.set(
    db.collection("service").doc("conf"),
    {
      admins: [user.uid],
      holidays: [],
      createdAt: new Date(),
    }
  );
  batch.set(db.collection("service").doc("version"), {version: 1});
  await batch.commit();
}

/**
 * Handles setup tasks triggered when the service/version document is deleted.
 * @param {Context} context - The function context containing logger, db, and auth.
 * @param {FirestoreEvent} event - The Firestore delete event.
 * @return {Promise<void>}
 */
export async function setup(
  context: Context,
  {data}: { data: DocumentSnapshot | undefined },
): Promise<void> {
  if (!data) {
    context.logger.info("No version document found, skipping setup");
    return;
  }

  const version = (data.get("version") as number) ?? 0;
  context.logger.info("Setting up for version", version);

  if (version < 1) {
    await setupV1(context, data);
  }
}
