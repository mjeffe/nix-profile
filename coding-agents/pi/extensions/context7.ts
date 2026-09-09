/**
 * Context7 Extension for pi
 *
 * Registers a `fetch_docs` tool that queries the Context7 API for current
 * library and framework documentation.  Context7 resolves documentation from
 * official sources, READMEs, and guides across thousands of packages.
 *
 * The tool resolves library names to Context7 library IDs (e.g., "react" ->
 * "/react/react"), then queries for documentation snippets.
 *
 * Setup:
 *   1. Place this file in ~/.pi/agent/extensions/
 *   2. Set your Context7 API key as an environment variable:
 *        export CONTEXT7_API_KEY="your-key-here"
 *      (add to ~/.profile, ~/.bashrc, or ~/.zshrc for persistence)
 *   3. Restart pi or run /reload.
 *
 * The LLM can then call fetch_docs(library, version?, topic?) to get
 * up-to-date documentation for any supported library.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const CONTEXT7_API_BASE = "https://context7.com";
const API_KEY = process.env.CONTEXT7_API_KEY;

// ---------------------------------------------------------------------------
// Tool parameter schema
// ---------------------------------------------------------------------------

const FetchDocsParams = Type.Object({
  library: Type.String({
    description:
      "Library or package name, e.g. 'react', 'next.js', 'laravel', 'vue', 'prisma', 'tailwindcss'",
  }),
  version: Type.Optional(
    Type.String({
      description:
        "Optional version specifier such as '18', 'latest', '^3.0', or '2.x'",
    }),
  ),
  topic: Type.Optional(
    Type.String({
      description:
        "Optional specific symbol, function, concept, or feature to look up, e.g. 'useState', 'middleware', 'migrations', 'routing'",
    }),
  ),
});

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/** Resolve a library name to a Context7 library ID like "/react/react". */
async function resolveLibrary(
  name: string,
  signal?: AbortSignal,
): Promise<{ id: string; title: string; description: string } | null> {
  const params = new URLSearchParams({ libraryName: name });
  const headers: Record<string, string> = {};
  if (API_KEY) headers["Authorization"] = `Bearer ${API_KEY}`;

  const response = await fetch(
    `${CONTEXT7_API_BASE}/api/v2/libs/search?${params}`,
    { headers, signal },
  );

  if (!response.ok) return null;

  const data = (await response.json()) as {
    results?: Array<{
      id: string;
      title: string;
      description: string;
    }>;
  };

  if (!data.results || data.results.length === 0) return null;

  const lib = data.results[0];
  return { id: lib.id, title: lib.title, description: lib.description };
}

// ---------------------------------------------------------------------------
// Extension
// ---------------------------------------------------------------------------

export default function (pi: ExtensionAPI) {
  if (!API_KEY) {
    console.error(
      "context7: CONTEXT7_API_KEY environment variable is not set. " +
        "The fetch_docs tool will return an error until it is configured.",
    );
  }

  pi.registerTool({
    name: "fetch_docs",
    label: "Fetch Docs (Context7)",
    description:
      "Fetch current library/framework documentation from Context7. " +
      "Use this when you need up-to-date API references, usage examples, " +
      "configuration details, or migration guides for a specific package. " +
      "Context7 aggregates official docs, READMEs, and guides across " +
      "thousands of libraries.",
    promptSnippet:
      "fetch_docs(library, version?, topic?): fetch current documentation " +
      "for a library/framework via Context7",
    promptGuidelines: [
      "Use fetch_docs before writing code against a library whose API you are uncertain about.",
      "Prefer fetch_docs over reading local node_modules/README when the installed version may differ from current docs.",
    ],
    parameters: FetchDocsParams,
    async execute(_toolCallId, params, signal) {
      // --- guard: missing API key -------------------------------------------
      if (!API_KEY) {
        return {
          content: [
            {
              type: "text",
              text:
                "Context7 API key is not configured. Set the " +
                "CONTEXT7_API_KEY environment variable in your shell " +
                "profile and restart pi (or run /reload).",
            },
          ],
          details: { error: "missing_api_key" },
          isError: true,
        };
      }

      const { library, version, topic } = params;

      try {
        // --- step 1: resolve library name to ID ----------------------------
        const lib = await resolveLibrary(library, signal);
        if (!lib) {
          return {
            content: [
              {
                type: "text",
                text: `No Context7 library found for "${library}". Try a more specific name.`,
              },
            ],
            details: { library, error: "not_found" },
            isError: true,
          };
        }

        // --- step 2: query documentation -----------------------------------
        const query = topic ?? "";
        const queryParams = new URLSearchParams({
          libraryId: lib.id,
          query,
        });
        if (version) queryParams.set("version", version);

        const response = await fetch(
          `${CONTEXT7_API_BASE}/api/v2/context?${queryParams}`,
          {
            headers: {
              Authorization: `Bearer ${API_KEY}`,
            },
            signal,
          },
        );

        if (!response.ok) {
          const errorBody = await response.text().catch(() => "(no body)");
          return {
            content: [
              {
                type: "text",
                text:
                  `Context7 API returned status ${response.status}: ${errorBody}`,
              },
            ],
            details: { error: "api_error", status: response.status },
            isError: true,
          };
        }

        const markdown = await response.text();

        if (!markdown || markdown.trim().length === 0) {
          const label = [library, version, topic]
            .filter(Boolean)
            .join(" / ");
          return {
            content: [
              {
                type: "text",
                text: `No documentation results found for "${label}".`,
              },
            ],
            details: { library, version, topic, libraryId: lib.id },
          };
        }

        const header =
          `Docs for **${lib.title}**` +
          ` (${lib.id})` +
          `${version ? ` @ ${version}` : ""}` +
          `${topic ? ` -- "${topic}"` : ""}` +
          `:\n\n`;

        return {
          content: [{ type: "text", text: header + markdown }],
          details: {
            library,
            libraryId: lib.id,
            libraryTitle: lib.title,
            version,
            topic,
          },
        };
      } catch (err) {
        const message =
          err instanceof Error ? err.message : String(err);
        return {
          content: [
            {
              type: "text",
              text: `Failed to reach Context7 API: ${message}`,
            },
          ],
          details: { error: "fetch_error", message },
          isError: true,
        };
      }
    },
  });
}
