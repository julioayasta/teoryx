export interface DocumentRecord<T = object> {
  id: string;
  data: T;
}

export interface DocumentStore {
  get<T extends object>(collection: string, id: string): Promise<T | undefined>;
  set<T extends object>(collection: string, id: string, data: T): Promise<void>;
  update<T extends object>(collection: string, id: string, data: Partial<T>): Promise<void>;
  list<T extends object>(collection: string): Promise<Array<DocumentRecord<T>>>;
  clear(): Promise<void>;
}

export class MemoryDocumentStore implements DocumentStore {
  private readonly collections = new Map<string, Map<string, Record<string, unknown>>>();

  async get<T extends object>(collection: string, id: string): Promise<T | undefined> {
    return this.collections.get(collection)?.get(id) as T | undefined;
  }

  async set<T extends object>(collection: string, id: string, data: T): Promise<void> {
    if (!this.collections.has(collection)) this.collections.set(collection, new Map());
    this.collections.get(collection)!.set(id, structuredClone(data) as Record<string, unknown>);
  }

  async update<T extends object>(collection: string, id: string, data: Partial<T>): Promise<void> {
    const existing = await this.get<object>(collection, id);
    if (!existing) throw new Error(`Document not found: ${collection}/${id}`);
    await this.set(collection, id, { ...existing, ...data });
  }

  async list<T extends object>(collection: string): Promise<Array<DocumentRecord<T>>> {
    return [...(this.collections.get(collection)?.entries() ?? [])].map(([id, data]) => ({
      id,
      data: structuredClone(data) as T,
    }));
  }

  async clear(): Promise<void> {
    this.collections.clear();
  }
}
