import {AuthBlockingEvent} from "firebase-functions/identity";
import {Context} from "./common";

/**
 * Handles the beforeUserCreated event by creating a Firestore user document.
 * @param {Context} context - The function context containing logger, db, and auth.
 * @param {AuthBlockingEvent} event - The auth blocking event containing user data.
 * @return {Promise<void>}
 */
export async function onUserCreating(
  {logger, db}: Context,
  event: AuthBlockingEvent,
): Promise<void> {
  const uid = event.data?.uid;

  if (!uid) {
    logger.error("No UID found in the event data");
    return;
  }

  logger.info("Creating user:", uid);

  await db.collection("users").doc(uid).set({
    createdAt: new Date(),
  });
}
