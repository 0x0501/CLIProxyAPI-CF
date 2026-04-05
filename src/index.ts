import { Container } from "@cloudflare/containers";
import { Hono } from "hono";

const app = new Hono<{ Bindings: Env }>();

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "*",
    "Access-Control-Allow-Methods": "GET,HEAD,POST,PUT,PATCH,DELETE,OPTIONS",
};

function withCors(response: Response) {
    const headers = new Headers(response.headers);

    for (const [key, value] of Object.entries(corsHeaders)) {
        headers.set(key, value);
    }

    // Switch protocol
    if (response.status === 101) {
        return response;
    }

    // 204 - No content
    // 205 - Reset content
    // 304 - Not Modified
    if ([204, 205, 304].includes(response.status)) {
        return new Response(null, {
            status: response.status,
            statusText: response.statusText,
            headers,
        });
    }

    return new Response(response.body, {
        status: response.status,
        statusText: response.statusText,
        headers,
    });
}

export class MyContainer extends Container<Env> {
    // Port the container listens on (default: 8080)
    defaultPort = 8317;

    // These ports are used by CLIProxyAPI.
    requiredPorts: number[] = [8317, 8085, 1455, 54545, 51121, 11451];

    // Time before container sleeps due to inactivity (default: 30s)
    sleepAfter = "5m";
    // Environment variables passed to the container
    envVars = {
        R2_BUCKET_NAME: this.env.R2_BUCKET_NAME,
        R2_ACCOUNT_ID: this.env.R2_ACCOUNT_ID,
        AWS_ACCESS_KEY_ID: this.env.AWS_ACCESS_KEY_ID,
        AWS_SECRET_ACCESS_KEY: this.env.AWS_SECRET_ACCESS_KEY,
    };

    enableInternet = true;

    // Optional lifecycle hooks
    override onStart() {
        console.log("Container successfully started");
    }

    override onStop() {
        console.log("Container successfully shut down");
    }

    override onError(error: unknown) {
        console.log("Container error:", error);
    }
}

app.all("/*", async (c) => {
    if (c.req.method === "OPTIONS") {
        return new Response(null, {
            status: 204,
            headers: corsHeaders,
        });
    }

    const containerId = c.env.MY_CONTAINER.idFromName(
        "hKqnASADsoqjmyl/zp7C8Gc1f1JaZLaN9lQOSjXjDb0=",
    );

    const container = c.env.MY_CONTAINER.get(containerId, {
        locationHint: "apac",
    });

    // get container state
    const state = await container.getState();

    if (state.status === "stopped" || state.status === "stopped_with_code") {
        await container.startAndWaitForPorts({
            ports: 8317,
        });
    }

    // degrade https to http, as websocket relay does not support https
    const url = new URL(c.req.url);
    url.protocol = "http";

    console.log(url);
    const newRequest = new Request(url.toString(), c.req.raw);

    return withCors(await container.fetch(newRequest));
});

export default app;
