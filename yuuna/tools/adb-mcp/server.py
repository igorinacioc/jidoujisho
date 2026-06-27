#!/usr/bin/env python3
"""
MCP server for Android Debug Bridge (adb) + agent-device.
Provides: screenshot, UI tree (adb + agent-device), tap (coords/element ID),
swipe, input text, key events, logcat, shell, app launch.

Usage: python server.py
Register in Claude Code's MCP settings as a stdio server.
"""

import asyncio
import base64
import os
import subprocess
import sys
from pathlib import Path

from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool, TextContent, ImageContent

# --- Paths ---
ADB_PATH = os.environ.get(
    "ADB_PATH",
    r"C:\Users\Family\AppData\Local\Android\Sdk\platform-tools\adb.exe",
)
ADB_DIR = str(Path(ADB_PATH).parent)
AGENT_DEVICE_CMD = os.environ.get(
    "AGENT_DEVICE_CMD",
    r"C:\Users\Family\AppData\Roaming\npm\agent-device.cmd",
)

# Ensure adb is in PATH for agent-device
os.environ["PATH"] = ADB_DIR + os.pathsep + os.environ.get("PATH", "")


def run_adb(*args: str, timeout: int = 15) -> subprocess.CompletedProcess:
    """Run an adb command synchronously."""
    cmd = [ADB_PATH] + list(args)
    return subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)


def run_adb_raw(*args: str, timeout: int = 15) -> subprocess.CompletedProcess:
    """Run adb and return raw bytes (for screenshots)."""
    cmd = [ADB_PATH] + list(args)
    return subprocess.run(cmd, capture_output=True, timeout=timeout)


def run_agent_device(*args: str, timeout: int = 30) -> subprocess.CompletedProcess:
    """Run an agent-device command via cmd.exe."""
    cmd = ["cmd.exe", "/c", AGENT_DEVICE_CMD] + list(args)
    return subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)


# --- MCP Server ---
server = Server("adb-mcp")


@server.list_tools()
async def list_tools() -> list[Tool]:
    return [
        Tool(
            name="screenshot",
            description="Take a screenshot from the Android device and return it as a base64-encoded PNG image.",
            inputSchema={"type": "object", "properties": {}},
        ),
        Tool(
            name="ui_tree",
            description="Get the UI hierarchy from the Android device as XML. Use to find coordinates for tapping.",
            inputSchema={"type": "object", "properties": {}},
        ),
        Tool(
            name="snapshot",
            description="Get interactive UI elements with IDs via agent-device. Returns elements like '@e5: button text'. Use these IDs with tap_element.",
            inputSchema={"type": "object", "properties": {}},
        ),
        Tool(
            name="tap",
            description="Tap at specific (x, y) coordinates on the device screen.",
            inputSchema={
                "type": "object",
                "properties": {
                    "x": {"type": "integer", "description": "X coordinate"},
                    "y": {"type": "integer", "description": "Y coordinate"},
                },
                "required": ["x", "y"],
            },
        ),
        Tool(
            name="tap_element",
            description="Tap an element by its agent-device ID (e.g., '@e5'). Use 'snapshot' first to discover element IDs.",
            inputSchema={
                "type": "object",
                "properties": {
                    "element_id": {"type": "string", "description": "Element ID like '@e5' from snapshot"},
                },
                "required": ["element_id"],
            },
        ),
        Tool(
            name="fill_field",
            description="Fill a text field identified by its agent-device element ID (e.g., '@e3').",
            inputSchema={
                "type": "object",
                "properties": {
                    "element_id": {"type": "string", "description": "Element ID like '@e3' from snapshot"},
                    "text": {"type": "string", "description": "Text to type into the field"},
                },
                "required": ["element_id", "text"],
            },
        ),
        Tool(
            name="swipe",
            description="Swipe from one point to another on the device screen.",
            inputSchema={
                "type": "object",
                "properties": {
                    "x1": {"type": "integer"}, "y1": {"type": "integer"},
                    "x2": {"type": "integer"}, "y2": {"type": "integer"},
                    "duration_ms": {"type": "integer", "description": "Duration in ms (default: 300)", "default": 300},
                },
                "required": ["x1", "y1", "x2", "y2"],
            },
        ),
        Tool(
            name="input_text",
            description="Type text into the currently focused field via adb.",
            inputSchema={
                "type": "object",
                "properties": {"text": {"type": "string"}},
                "required": ["text"],
            },
        ),
        Tool(
            name="key_event",
            description="Send an Android key event. Common: BACK=4, HOME=3, ENTER=66, DEL=67, DPAD_UP=19, DPAD_DOWN=20.",
            inputSchema={
                "type": "object",
                "properties": {"keycode": {"type": "integer"}},
                "required": ["keycode"],
            },
        ),
        Tool(
            name="logcat",
            description="Get filtered logcat output for debugging crashes and errors.",
            inputSchema={
                "type": "object",
                "properties": {
                    "filter": {"type": "string", "description": "Filter pattern (e.g., 'flutter', 'PLogger', 'ERROR')"},
                    "lines": {"type": "integer", "description": "Number of lines (default: 100)", "default": 100},
                    "clear_before": {"type": "boolean", "description": "Clear logcat first (default: false)", "default": False},
                },
            },
        ),
        Tool(
            name="shell",
            description="Run an arbitrary adb shell command and return output.",
            inputSchema={
                "type": "object",
                "properties": {"command": {"type": "string"}},
                "required": ["command"],
            },
        ),
        Tool(
            name="list_devices",
            description="List all connected Android devices/emulators.",
            inputSchema={"type": "object", "properties": {}},
        ),
        Tool(
            name="launch_app",
            description="Launch an Android app by package name and activity.",
            inputSchema={
                "type": "object",
                "properties": {
                    "package": {"type": "string", "description": "e.g. 'app.arianneorpilla.yuuna'"},
                    "activity": {"type": "string", "description": "e.g. '.MainActivity'"},
                },
                "required": ["package", "activity"],
            },
        ),
        Tool(
            name="open_app",
            description="Open an app via agent-device (sets up a session for snapshot/tap_element/fill_field).",
            inputSchema={
                "type": "object",
                "properties": {
                    "package": {"type": "string", "description": "e.g. 'app.arianneorpilla.yuuna'"},
                },
                "required": ["package"],
            },
        ),
        Tool(
            name="force_stop",
            description="Force-stop an Android app by package name.",
            inputSchema={
                "type": "object",
                "properties": {
                    "package": {"type": "string", "description": "e.g. 'app.arianneorpilla.yuuna'"},
                },
                "required": ["package"],
            },
        ),
    ]


@server.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent | ImageContent]:
    try:
        handlers = {
            "screenshot": _handle_screenshot,
            "ui_tree": _handle_ui_tree,
            "snapshot": _handle_snapshot,
            "tap": lambda: _handle_tap(arguments["x"], arguments["y"]),
            "tap_element": lambda: _handle_tap_element(arguments["element_id"]),
            "fill_field": lambda: _handle_fill_field(arguments["element_id"], arguments["text"]),
            "swipe": lambda: _handle_swipe(arguments["x1"], arguments["y1"], arguments["x2"], arguments["y2"], arguments.get("duration_ms", 300)),
            "input_text": lambda: _handle_input_text(arguments["text"]),
            "key_event": lambda: _handle_key_event(arguments["keycode"]),
            "logcat": lambda: _handle_logcat(arguments.get("filter"), arguments.get("lines", 100), arguments.get("clear_before", False)),
            "shell": lambda: _handle_shell(arguments["command"]),
            "list_devices": _handle_list_devices,
            "launch_app": lambda: _handle_launch_app(arguments["package"], arguments["activity"]),
            "open_app": lambda: _handle_open_app(arguments["package"]),
            "force_stop": lambda: _handle_force_stop(arguments["package"]),
        }
        handler = handlers.get(name)
        if handler:
            return await handler()
        return [TextContent(type="text", text=f"Unknown tool: {name}")]
    except Exception as e:
        return [TextContent(type="text", text=f"Error: {str(e)}")]


# --- Handlers ---

async def _handle_screenshot() -> list[TextContent | ImageContent]:
    result = run_adb_raw("exec-out", "screencap", "-p")
    if result.returncode != 0:
        return [TextContent(type="text", text=f"adb error: {result.stderr.decode() if result.stderr else 'unknown'}")]
    b64 = base64.b64encode(result.stdout).decode("ascii")
    return [ImageContent(type="image", data=b64, mimeType="image/png")]


async def _handle_ui_tree() -> list[TextContent | ImageContent]:
    run_adb("shell", "uiautomator", "dump", "/sdcard/ui_tree.xml")
    result = run_adb("exec-out", "cat", "/sdcard/ui_tree.xml")
    return [TextContent(type="text", text=result.stdout[:50000])]


async def _handle_snapshot() -> list[TextContent | ImageContent]:
    """Get interactive elements with IDs via agent-device."""
    result = run_agent_device("snapshot", "-i", timeout=20)
    return [TextContent(type="text", text=result.stdout + result.stderr)]


async def _handle_tap(x: int, y: int) -> list[TextContent | ImageContent]:
    result = run_adb("shell", "input", "tap", str(x), str(y))
    return [TextContent(type="text", text=f"Tapped ({x}, {y})")]


async def _handle_tap_element(element_id: str) -> list[TextContent | ImageContent]:
    result = run_agent_device("tap", element_id, timeout=15)
    return [TextContent(type="text", text=f"Tapped {element_id}\n{result.stdout}{result.stderr}")]


async def _handle_fill_field(element_id: str, text: str) -> list[TextContent | ImageContent]:
    result = run_agent_device("fill", element_id, text, timeout=15)
    return [TextContent(type="text", text=f"Filled {element_id} with '{text}'\n{result.stdout}{result.stderr}")]


async def _handle_swipe(x1: int, y1: int, x2: int, y2: int, dur: int) -> list[TextContent | ImageContent]:
    run_adb("shell", "input", "swipe", str(x1), str(y1), str(x2), str(y2), str(dur))
    return [TextContent(type="text", text=f"Swiped ({x1},{y1}) → ({x2},{y2})")]


async def _handle_input_text(text: str) -> list[TextContent | ImageContent]:
    escaped = text.replace(" ", "%s")
    run_adb("shell", "input", "text", escaped)
    return [TextContent(type="text", text=f"Typed: '{text}'")]


async def _handle_key_event(keycode: int) -> list[TextContent | ImageContent]:
    run_adb("shell", "input", "keyevent", str(keycode))
    return [TextContent(type="text", text=f"Key event: {keycode}")]


async def _handle_logcat(filter_str: str | None, lines: int, clear: bool) -> list[TextContent | ImageContent]:
    if clear:
        run_adb("logcat", "-c")
    result = run_adb("logcat", "-d", "-t", str(lines))
    output = result.stdout
    if filter_str:
        filtered = [l for l in output.split("\n") if filter_str in l]
        output = "\n".join(filtered[-lines:])
    return [TextContent(type="text", text=output[:10000])]


async def _handle_shell(command: str) -> list[TextContent | ImageContent]:
    result = run_adb("shell", command, timeout=20)
    return [TextContent(type="text", text=(result.stdout + result.stderr)[:10000])]


async def _handle_list_devices() -> list[TextContent | ImageContent]:
    result = run_adb("devices", "-l")
    return [TextContent(type="text", text=result.stdout)]


async def _handle_launch_app(package: str, activity: str) -> list[TextContent | ImageContent]:
    result = run_adb("shell", "am", "start", "-n", f"{package}/{activity}")
    return [TextContent(type="text", text=result.stdout + result.stderr)]


async def _handle_open_app(package: str) -> list[TextContent | ImageContent]:
    result = run_agent_device("open", package, "--platform", "android", timeout=20)
    return [TextContent(type="text", text=result.stdout + result.stderr)]


async def _handle_force_stop(package: str) -> list[TextContent | ImageContent]:
    result = run_adb("shell", "am", "force-stop", package)
    return [TextContent(type="text", text=f"Force stopped {package}")]


async def main():
    async with stdio_server() as (read_stream, write_stream):
        await server.run(read_stream, write_stream, server.create_initialization_options())


if __name__ == "__main__":
    asyncio.run(main())
