#!/usr/bin/env python3
import sys
import os
import getopt
import subprocess
import plistlib
import operator

class UsageException(Exception):
    pass

class CheckException(Exception):
    def __init__(self, message, path=None):
        self.message = message
        self.path = path

def checkCodeSignature(programPath, programType):
    try:
        subprocess.check_call(["codesign", "-v", "-v", programPath], stderr=subprocess.DEVNULL)
    except subprocess.CalledProcessError:
        raise CheckException(f"{programType} code signature invalid", programPath)

def readDesignatedRequirement(programPath, programType):
    try:
        req = subprocess.check_output(["codesign", "-d", "-r", "-", programPath], stderr=subprocess.DEVNULL).decode("utf-8")
    except subprocess.CalledProcessError:
        raise CheckException(f"{programType} designated requirement unreadable", programPath)
    reqLines = req.splitlines()
    if len(reqLines) != 1 or not reqLines[0].startswith("designated => "):
        raise CheckException(f"{programType} designated requirement malformed", programPath)
    return reqLines[0][len("designated => "):]

def readInfoPlistFromPath(infoPath):
    try:
        with open(infoPath, "rb") as fp:
            info = plistlib.load(fp)
    except:
        raise CheckException("'Info.plist' not readable", infoPath)
    if not isinstance(info, dict):
        raise CheckException("'Info.plist' root must be a dictionary", infoPath)
    return info

def setreq(appPath, appInfoPlistPath, toolInfoPlistPaths):
    if not os.path.isdir(appPath):
        raise CheckException("app not found", appPath)

    if not os.path.isfile(appInfoPlistPath):
        raise CheckException("app 'Info.plist' not found", appInfoPlistPath)
    for toolInfoPlistPath in toolInfoPlistPaths:
        if not os.path.isfile(toolInfoPlistPath):
            raise CheckException("tool 'Info.plist' not found", toolInfoPlistPath)

    appReq = readDesignatedRequirement(appPath, "app")
    toolDirPath = os.path.join(appPath, "Contents", "Library", "LaunchServices")
    if not os.path.isdir(toolDirPath):
        raise CheckException("tool directory not found", toolDirPath)

    toolNameToReqMap = {}
    for toolName in os.listdir(toolDirPath):
        req = readDesignatedRequirement(os.path.join(toolDirPath, toolName), "tool")
        toolNameToReqMap[toolName] = req

    if len(toolNameToReqMap) != len(toolInfoPlistPaths):
        raise CheckException("Mismatch in tool count and provided Info.plist paths", toolDirPath)

    appToolDict = {}
    toolInfoPlistPathToToolInfoMap = {}
    for toolInfoPlistPath in toolInfoPlistPaths:
        toolInfo = readInfoPlistFromPath(toolInfoPlistPath)
        toolInfoPlistPathToToolInfoMap[toolInfoPlistPath] = toolInfo
        bundleID = toolInfo.get("CFBundleIdentifier")
        if not bundleID:
            raise CheckException("'CFBundleIdentifier' not found", toolInfoPlistPath)
        appToolDict[bundleID] = toolNameToReqMap.get(bundleID)

    appInfo = readInfoPlistFromPath(appInfoPlistPath)
    needsUpdate = appInfo.get("SMPrivilegedExecutables") != appToolDict
    if needsUpdate:
        appInfo["SMPrivilegedExecutables"] = appToolDict
        with open(appInfoPlistPath, "wb") as fp:
            plistlib.dump(appInfo, fp)
        print(f"{appInfoPlistPath}: updated")

    for toolInfoPlistPath in toolInfoPlistPaths:
        toolInfo = toolInfoPlistPathToToolInfoMap[toolInfoPlistPath]
        if toolInfo.get("SMAuthorizedClients") != [appReq]:
            toolInfo["SMAuthorizedClients"] = [appReq]
            with open(toolInfoPlistPath, "wb") as fp:
                plistlib.dump(toolInfo, fp)
            print(f"{toolInfoPlistPath}: updated")

def main():
    try:
        options, appArgs = getopt.getopt([arg for arg in sys.argv[1:] if not arg.startswith('-f')], "d")
        if len(appArgs) == 0:
            raise UsageException()
        command = appArgs[0]
        if command == "check":
            if len(appArgs) != 2:
                raise UsageException()
            # check(appArgs[1])  # Optional check step
        elif command == "setreq":
            if len(appArgs) < 4:
                raise UsageException()
            setreq(appArgs[1], appArgs[2], appArgs[3:])
        else:
            raise UsageException()
    except CheckException as e:
        if e.path:
            print(f"{e.path}: {e.message}", file=sys.stderr)
        else:
            print(f"{os.path.basename(sys.argv[0])}: {e.message}", file=sys.stderr)
        sys.exit(1)
    except UsageException:
        cmd = os.path.basename(sys.argv[0])
        print(f"usage: {cmd} check  /path/to/app", file=sys.stderr)
        print(f"       {cmd} setreq /path/to/app /path/to/app/Info.plist /path/to/tool/Info.plist...", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()


#python3 ./SMJobBlessUtil_fixed.py setreq \                                                                            ✔  at 14:00:45  ▓▒░
#"/Users/sachinkumar/Library/Developer/Xcode/DerivedData/Scriptex-bonwcrbscfbjutdlvamjxgqybzwr/Build/Products/Debug/Scriptex.app" \
#"/Users/sachinkumar/Desktop/Scriptex/Scriptex/Info.plist" \
#"/Users/sachinkumar/Desktop/Scriptex/Helper/Info.plist"
