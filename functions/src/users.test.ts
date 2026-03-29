/* eslint-disable require-jsdoc */
import {describe, it, expect, vi, beforeEach} from "vitest";
import {onUserCreating} from "./users";
import type {Context} from "./common";
import type {AuthBlockingEvent} from "firebase-functions/identity";

function makeContext(overrides?: Partial<Context>) {
  const set = vi.fn().mockResolvedValue(undefined);
  const doc = vi.fn().mockReturnValue({set});
  const collection = vi.fn().mockReturnValue({doc});

  const db = {collection};
  const logger = {
    info: vi.fn(),
    error: vi.fn(),
  };

  const context = {logger, db, ...overrides} as unknown as Context;

  return {context, logger, collection, doc, set};
}

describe("onUserCreating", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("logs error and returns when uid is missing", async () => {
    const {context, logger, collection} = makeContext();
    const event = {data: {uid: undefined}} as unknown as AuthBlockingEvent;

    await onUserCreating(context, event);

    expect(logger.error).toHaveBeenCalledWith(
      "No UID found in the event data"
    );
    expect(collection).not.toHaveBeenCalled();
  });

  it("creates user document when uid is present", async () => {
    const {context, logger, collection, doc, set} = makeContext();
    const event = {data: {uid: "user-123"}} as unknown as AuthBlockingEvent;

    await onUserCreating(context, event);

    expect(logger.info).toHaveBeenCalledWith("Creating user:", "user-123");
    expect(collection).toHaveBeenCalledWith("users");
    expect(doc).toHaveBeenCalledWith("user-123");
    expect(set).toHaveBeenCalledTimes(1);
    expect(set).toHaveBeenCalledWith(
      expect.objectContaining({createdAt: expect.any(Date)})
    );
  });
});
