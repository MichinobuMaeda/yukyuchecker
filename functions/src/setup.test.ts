/* eslint-disable require-jsdoc */
import {describe, it, expect, vi, beforeEach} from "vitest";
import {setup} from "./setup";
import type {Context} from "./common";
import type {
  DocumentSnapshot,
  DocumentReference,
  WriteBatch,
  CollectionReference,
} from "firebase-admin/firestore";

function makeDocSnapshot(
  fields: Record<string, unknown>,
  ref?: Partial<DocumentReference>
): DocumentSnapshot {
  return {
    get: (field: string) => fields[field],
    ref: {update: vi.fn(), ...ref} as unknown as DocumentReference,
  } as unknown as DocumentSnapshot;
}

function makeContext(overrides?: Partial<Context>): Context {
  const batch = {
    set: vi.fn(),
    update: vi.fn(),
    commit: vi.fn().mockResolvedValue(undefined),
  } as unknown as WriteBatch;

  const confDocRef = {id: "conf"} as unknown as DocumentReference;
  const serviceCollection = {
    doc: vi.fn().mockReturnValue(confDocRef),
  } as unknown as CollectionReference;

  const db = {
    batch: vi.fn().mockReturnValue(batch),
    collection: vi.fn().mockReturnValue(serviceCollection),
  };

  const auth = {
    createUser: vi.fn().mockResolvedValue({uid: "test-uid"}),
  };

  const logger = {
    info: vi.fn(),
    error: vi.fn(),
  };

  return {logger, db, auth, ...overrides} as unknown as Context;
}

describe("setup", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("does nothing when data is undefined", async () => {
    const ctx = makeContext();
    await setup(ctx, {data: undefined});
    expect(ctx.logger.info).toHaveBeenCalledWith("Setting up for version", 0);
  });

  it("does nothing when version >= 1", async () => {
    const ctx = makeContext();
    const data = makeDocSnapshot({version: 1});
    await setup(ctx, {data});
    expect(ctx.auth.createUser).not.toHaveBeenCalled();
  });

  it("calls setupV1 when version is 0", async () => {
    const ctx = makeContext();
    const data = makeDocSnapshot({version: 0, email: "admin@example.com"});
    await setup(ctx, {data});
    expect(
      ctx.auth.createUser
    ).toHaveBeenCalledWith({email: "admin@example.com"});
    expect(ctx.db.batch().commit).toHaveBeenCalled();
  });

  it("logs error and returns when no email in version document", async () => {
    const ctx = makeContext();
    const data = makeDocSnapshot({version: 0, email: undefined});
    await setup(ctx, {data});
    expect(
      ctx.logger.error
    ).toHaveBeenCalledWith("No admin email provided in the version document");
    expect(ctx.auth.createUser).not.toHaveBeenCalled();
  });
});
