# sim-helpers

One `sim` command for everyday iOS Simulator chores: drop files and whole folders into the Files app, add photos and videos, push your Mac clipboard, and open or measure your apps' data and cache folders.

[Tiếng Việt bên dưới](#tiếng-việt)

```text
$ sim file F=~/Downloads/report.pdf
✔ Copied report.pdf → Files › On My iPhone

$ sim size dev
== com.example.app.dev  /Users/you/Library/Developer/CoreSimulator/Devices/…
301M  …/tmp
225M  …/Library/Caches/videos
```

## Install

Needs macOS with Xcode (for `xcrun simctl`) and `make` (comes with the Xcode command line tools).

```bash
curl -fsSL https://raw.githubusercontent.com/tranhieudevvietnam/sim-helpers/main/install.sh | sh
```

Or from a clone:

```bash
git clone https://github.com/tranhieudevvietnam/sim-helpers.git && cd sim-helpers && ./install.sh
```

This puts the `sim` command in `~/.local/bin` and `sim.mk` in `~/.local/share/sim`. If `~/.local/bin` is not on your `PATH`, the installer prints the line to add to `~/.zshrc`.

Run the same command again to update. Your config is kept.

## Name your apps (optional)

So you can type `sim cache dev` instead of a bundle id:

```bash
sim config
```

That creates `~/.config/sim/config.mk`. Uncomment and edit it:

```make
FLAVORS := dev prod
FLAVOR_dev  := com.example.app.dev
FLAVOR_prod := com.example.app
```

## Commands

| Command | What it does |
|---|---|
| `sim file F=<path>` | Copy a file or a whole folder into Files › On My iPhone |
| `sim photo F=<path>` | Add an image or video to the Photos app |
| `sim open` | Open Files › On My iPhone in Finder, to drag files or folders in |
| `sim ls` | List what is in Files › On My iPhone |
| `sim paste` | Copy the Mac clipboard to the simulator clipboard (see the note below) |
| `sim list [name]` | Show the installed apps and their data container |
| `sim cache [name]` | Open each app's `Library/Caches` in Finder |
| `sim dir [name]` | Open each app's data container in Finder |
| `sim size [name]` | Sizes of each app's caches, `tmp` and `Documents` |
| `sim config` | Show (and create) your app names file |
| `sim version` | Show the installed version |

Run `sim` alone for this list.

- Without a name, `list`, `cache`, `dir` and `size` use every app in your config. Name one or more (`sim cache dev prod`), or pass a bundle id with `APP=com.example.app`.
- Commands use the booted simulator. Pick another with `SIM="iPhone 17 Pro"` or a UDID.
- `F` paths are relative to the folder you run `sim` from. `F=~/…` works in zsh too.

## Clipboard note (Xcode 27 Device Hub)

In Xcode 27.2, Device Hub's **Use Shared Clipboard** syncs the Mac clipboard to the simulator but hands it over one step late: the first paste in an app comes back empty or shows the previous clipboard, and the next paste is right. While it is on, it also replaces anything `sim paste` writes, and `sim paste` warns you when that happens.

Either press Paste twice, or turn **Use Shared Clipboard** off in Device Hub and use `sim paste`.

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/tranhieudevvietnam/sim-helpers/main/uninstall.sh | sh
```

Add `-s -- --purge` after `sh` to also delete `~/.config/sim`. From a clone: `./uninstall.sh` or `./uninstall.sh --purge`.

If you had an older `alias sim=…` in `~/.zshrc`, remove it: an alias wins over the installed command.

---

## Tiếng Việt

Một lệnh `sim` cho các việc hay làm với iOS Simulator: chép file hoặc cả thư mục vào app Files, thêm ảnh/video, đẩy clipboard của Mac sang máy ảo, mở hoặc xem dung lượng thư mục data và cache của app.

### Cài đặt

Cần macOS có Xcode (để dùng `xcrun simctl`) và `make` (có sẵn trong Xcode command line tools).

```bash
curl -fsSL https://raw.githubusercontent.com/tranhieudevvietnam/sim-helpers/main/install.sh | sh
```

Lệnh `sim` được cài vào `~/.local/bin`. Nếu thư mục này chưa có trong `PATH`, trình cài đặt sẽ in ra dòng cần thêm vào `~/.zshrc`. Chạy lại lệnh cài là cập nhật, cấu hình của bạn vẫn được giữ.

### Đặt tên cho app (không bắt buộc)

Chạy `sim config` để tạo `~/.config/sim/config.mk`, bỏ dấu `#` rồi sửa bundle id cho đúng app của bạn. Sau đó gõ được `sim cache dev` thay vì bundle id.

### Các lệnh

| Lệnh | Tác dụng |
|---|---|
| `sim file F=<đường dẫn>` | Chép file hoặc cả thư mục vào Files › On My iPhone |
| `sim photo F=<đường dẫn>` | Thêm ảnh/video vào app Photos |
| `sim open` | Mở thư mục On My iPhone trong Finder để kéo-thả |
| `sim ls` | Xem trong On My iPhone đang có gì |
| `sim paste` | Chép clipboard Mac sang máy ảo (xem ghi chú bên dưới) |
| `sim list [tên]` | Liệt kê app đã cài và thư mục data |
| `sim cache [tên]` | Mở `Library/Caches` của app trong Finder |
| `sim dir [tên]` | Mở thư mục data của app trong Finder |
| `sim size [tên]` | Dung lượng cache, `tmp`, `Documents` của app |
| `sim config` | Xem (và tạo) file đặt tên app |
| `sim version` | Xem phiên bản |

Chọn máy ảo khác bằng `SIM="iPhone 17 Pro"` hoặc UDID. Truyền bundle id trực tiếp bằng `APP=com.example.app`.

### Ghi chú về clipboard (Device Hub của Xcode 27)

Trên Xcode 27.2, **Use Shared Clipboard** của Device Hub đồng bộ clipboard nhưng bị trễ một nhịp: lần paste đầu tiên trong app ra rỗng hoặc ra nội dung cũ, lần sau mới đúng. Khi tính năng này bật, nó còn ghi đè nội dung `sim paste` vừa chép (lệnh sẽ báo cho bạn). Cách xử lý: bấm Paste hai lần, hoặc tắt **Use Shared Clipboard** trong Device Hub rồi dùng `sim paste`.

### Gỡ cài đặt

Chạy `uninstall.sh` (thêm `--purge` để xoá luôn `~/.config/sim`). Nếu trước đây bạn có `alias sim=…` trong `~/.zshrc` thì xoá dòng đó đi, vì alias sẽ được ưu tiên hơn lệnh đã cài.

## License

MIT
