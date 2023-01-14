# Lua File System Utils

The fs module is a set of functions that provide various file system related functionality, such as finding, reading,
writing and streaming files.

### Functions

**find(path, name)**

The find function searches for a file with the given name in the directory specified by path. It returns the full path
to the file if it is found, otherwise it returns nil.

```lua
local path = fs.find('/home/user', 'example.txt')
print(path) -- '/home/user/example.txt'
```

**fileName(path)**

The fileName function takes a file path as an argument and returns the file name from the path.

```lua
local fileName = fs.fileName('/home/user/example.txt')
print(fileName) -- 'example.txt'
```

**fileExtension(path)**

The fileExtension function takes a file path as an argument and returns the file extension from the path.

```lua
local fileExtension = fs.fileExtension('/home/user/example.txt')
print(fileExtension) -- 'txt'
```

**readAsText(path)**

The readAsText function reads the file at the specified path and returns its content as a string.

```lua
local fileContent = fs.readAsText('/home/user/example.txt')
print(fileContent) -- 'This is an example text file.'
```

**readAsJson(path)**

The readAsJson function reads the file at the specified path, converts it to a JSON object, and returns the object.

```lua
local fileContent = fs.readAsJson('/home/user/example.json')
print(fileContent) -- { name: "example", value: 42 }
```

**read(path, binary)**

The read function reads the file at the specified path and returns its content as an array of bytes. If the binary
parameter is set to true, the file will be read in binary mode, otherwise it will be read in text mode.

Reading binary file:

```lua
local fileContent = fs.read('/home/user/example.bin', true)
print(fileContent) -- { 0x01, 0x02, 0x03, ... }
```

Reading file as text, similar to `readAsText`:

```lua
local fileContent = fs.read('/home/user/example.txt', false)
print(fileContent) -- 'This is an example text file.'
```

**write(path, content)**

The write function writes the content to the file at the specified path.

```lua
fs.write('/home/user/example.txt', 'This is new content')
```

**exists(path)**

The exists function checks if the file or directory at the specified path exists and returns true if it does, otherwise
false.

```lua
local exists = fs.exists('/home/user/example.txt')
print(exists) -- true
```

**filesCount(path)**

The filesCount function returns the number of files in a given folder path.

```lua
local filesCount = fs.filesCount('/home/user')
print(filesCount) -- 3
```

**matchSignature(path, signature)**

The matchSignature function accepts a path — a path to the file and signature - array of bytes. It checks if the path is
file, and it exists, then checks if file content starts with 'signature'. return true if matched, otherwise

```lua
local match = fs.matchSignature('/home/user/example.txt', { 'T', 'h', 'i', 's', ' ', 'i', 's' })
print(match) -- true
```

**stream(path, chunkSize)**

Streams file to stdout or, if running under openresty to the user, the chunkSize is optional

```lua
fs.stream('/home/user/example.mp4',8192)
```