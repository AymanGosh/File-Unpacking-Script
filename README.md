
# Usage Examples

Each example below shows the command, its output, and explains what happened:

## 1. Basic Usage
**Command:**  
```sh
~/my-folder$ unpack my-zip-file
```
**Output:**  
```
Decompressed 1 archive(s)
```
- The contents of `my-zip-file` were written back into the directory `my-folder`.
- Command returned `0` (success).

---

## 2. Multiple Files
**Command:**  
```sh
~/my-folder$ unpack my-zip-file my-bz2-file
```
**Output:**  
```
Decompressed 2 archive(s)
```
- The contents of both `my-zip-file` and `my-bz2-file` were written into the directory `my-folder`.
- Command returned `0` (success).

---

## 3. Non-Archive File
**Command:**  
```sh
~/my-folder$ unpack some-text-file
```
**Output:**  
```
Decompressed 0 archive(s)
```
- Command returned `1` (failure for 1 file).
- No decompression was performed as the file wasn't an archive.

---

## 4. Verbose Mode with Multiple Files
**Command:**  
```sh
~/my-folder$ unpack -v *
```
**Output:**  
```
Unpacking my-bz2-file...
Unpacking my-zip-file...
Ignoring some-text-file
Decompressed 2 archive(s)
```
- Directory `~/my-folder` contained three files: `some-text-file`, `my-zip-file`, and `my-bz2-file`.
- The contents of `my-zip-file` and `my-bz2-file` were written into `~/my-folder`.
- `some-text-file` was ignored (not an archive).
- Command returned `1` (failure for 1 file).

---

## 5. Directory Handling (Non-Recursive)
**Command:**  
```sh
~/my-folder$ unpack -d some-directory
```
**Output:**  
```
Decompressed 3 archive(s)
```
- The contents of all archives in `some-directory` were extracted into `~/my-folder`.
- Command returned `0` (success).


# To-Do

## 4. Scoring cc 