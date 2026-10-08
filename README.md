# nixos
 nixos flake
## Preview
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/5d1e1a36-ad2b-4299-b510-32ca716e3fc7" />

## Компоненты с настройками OS и Home

Модули находятся в `/home/acup/flakes/modules`, рядом с репозиторием
`/home/acup/flakes/nixos`. Путь к ним задаётся прямо в `modules.nix`
переменной `modulesRoot`; отдельный input для модулей не нужен.
Внутри компонентов используется та же организация, что у основной конфигурации:

```text
flakes/
├── nixos/
│   └── flake.nix
└── modules/
    ├── base/
    │   ├── default.nix
    │   ├── nixos.nix
    │   ├── configuration/
    │   └── packages/base.nix
    ├── qbittorrent/
    ├── nix-serve/
    ├── bootloader/
    │   ├── default.nix
    │   ├── nixos.nix
    │   ├── configuration/bootloader.nix
    │   └── grub_themes/intervals-grub-theme/
    ├── sunshine/
    │   ├── default.nix
    │   ├── nixos.nix
    │   ├── home.nix
    │   ├── configuration/
    │   │   └── sunshine.nix
    │   └── home_packages/hypr/
    │       ├── default.nix
    │       └── .config/hypr/sunshine.lua
    ├── sunshine-frp/
    │   ├── default.nix
    │   ├── nixos.nix
    │   └── configuration/frp.nix
    ├── moonlight/
    │   ├── default.nix
    │   ├── nixos.nix
    │   └── packages/moonlight.nix
    ├── terminal/
    │   ├── default.nix
    │   ├── nixos.nix
    │   ├── home.nix
    │   ├── packages/
    │   │   ├── clitools.nix
    │   │   └── terminal.nix
    │   └── home_packages/
    │       ├── btop/
    │       ├── cava/
    │       ├── yazi/
    │       └── zsh/
    ├── browsers/
    │   ├── default.nix
    │   ├── nixos.nix
    │   └── packages/
    │       ├── browsers.nix
    │       └── zen.nix
    ├── WM-DE/
    │   ├── common/
    │   │   ├── default.nix
    │   │   ├── nixos.nix
    │   │   ├── home.nix
    │   │   ├── configuration/
    │   │   ├── packages/desktop.nix
    │   │   └── home_packages/
    │   │       ├── dms/
    │   │       ├── theming/
    │   │       ├── waybar/
    │   │       └── waylandkb/
    │   ├── hypr/
    │   ├── niri/
    │   ├── drift/
    │   └── gnome/
    └── caelestia-shell/
```

`flake.nix` напрямую импортирует `/home/acup/flakes/modules.nix` (файл также
доступен как `~/.config/nix/modules.nix`). Селектор находится вне графа flake
inputs и не фиксируется в `flake.lock`; прямой импорт требует `--impure`. Один
импорт выбирает обе части компонента. `sunshine-frp` и Moonlight подключаются
независимо от Sunshine:

```nix
{...}: let
  modulesRoot = /home/acup/flakes/modules;
in [
  (import (modulesRoot + "/base"))
  (import (modulesRoot + "/bootloader"))
  (import (modulesRoot + "/caelestia-shell"))
  (import (modulesRoot + "/browsers"))
  (import (modulesRoot + "/qbittorrent"))
  (import (modulesRoot + "/nix-serve"))
  (import (modulesRoot + "/sunshine"))
  (import (modulesRoot + "/sunshine-frp"))
  (import (modulesRoot + "/moonlight"))
  (import (modulesRoot + "/terminal"))
  (import (modulesRoot + "/WM-DE/hypr"))
  (import (modulesRoot + "/WM-DE/niri"))
  (import (modulesRoot + "/WM-DE/drift"))
  (import (modulesRoot + "/WM-DE/gnome"))
]
```

При первом развёртывании создай файл выбора из примера. Команды выполняются
из каталога `nixos/`:

```sh
mkdir -p ~/.config/nix
cp ../modules/selection.example.nix ~/.config/nix/modules.nix
```

При другом расположении модулей измени `modulesRoot` в `modules.nix`. Изменения
селектора и файлов компонентов подхватываются при следующей оценке и не требуют
обновления `flake.lock`.

Для доступа к локальным модулям вне flake нужен `--impure` при сборке
или применении NixOS и Home Manager. Например, для применения вручную:

```sh
sudo nixos-rebuild switch --flake .#nixos --impure
home-manager switch --flake .#acup --impure
```

Настроенная в `../modules/base/configuration/nh.nix` обёртка добавляет этот флаг для команд
сборки и применения NixOS, а также `nh home switch` и `nh home build`.
Она обновится после применения системной конфигурации.

`default.nix` компонента экспортирует
`{ nixos = import ./nixos.nix; home = import ./home.nix; }`; ненужную часть
можно опустить. `nixos.nix` рекурсивно импортирует файлы из `configuration/`
и `packages/` через `lib.filesystem.listFilesRecursive`. `home.nix` автоматически
выбирает только `default.nix` из `home_packages/`. Функция выбора также получает
`inputs` для подключения отдельно объявленных репозиториев.

Основной flake сохраняет выходы `nixosConfigurations.nixos` и
`homeConfigurations.acup`; их применение выполняется отдельно.

Sunshine использует `inputs.hyprland` и `username` основной конфигурации и
предполагает включённый Hyprland. Сохранены существующие автологин в Hyprland
и открытие портов Sunshine. Отдельный компонент `sunshine-frp` содержит
FRP-прокси, включая проброс SSH на порт 2224; его настройки перенесены без
изменений. Токен FRP остаётся во внешнем файле `/etc/frp-sunshine.env`.

`bootloader` содержит исходные настройки GRUB для UEFI (`device = "nodev"`),
тему Intervals со всеми исходниками, разрешение 1920×1080, таймаут 2 секунды
и разрешение изменения EFI-переменных. Содержимое исходного `bootloader.nix`,
включая эмуляцию `aarch64-linux`, перенесено без изменений.

`terminal` объединяет дополнительные CLI-пакеты из `packages/clitools.nix`,
Alacritty из `packages/terminal.nix`, а также Home Manager настройки
btop, cava, yazi и zsh. Его `nixos.nix` автоматически
импортирует файлы из `packages/`.
Настройки zsh взяты из ветки `macos`: Starship, алиасы и сочетания клавиш,
включая `nixfullrebuild`, без автоматического запуска pokemon-colorscripts.
Команда `nixrebuild` выбирает `nixos-rebuild` или `darwin-rebuild` по платформе;
`pmset` и путь Homebrew включаются только на macOS. Сочетание для
pokemon-colorscripts включается, если команда установлена. Системный выбор
zsh как оболочки пользователя остаётся в основной конфигурации NixOS.

## Категории системных пакетов и модули

Все категории пакетов и сопутствующих сервисов вынесены в отдельные подключаемые модули в `../modules/`:

| Модуль | Описание |
| --- | --- |
| `android` | Waydroid и DroidCam |
| `dev` | Компиляторы, языки и инструменты разработки |
| `devops` | Docker, Kubernetes, QEMU, libvirtd, Terraform |
| `doc-redactors` | Офисные пакеты, LaTeX, Typst, PDF и Obsidian |
| `file-viewers` | Файловые менеджеры и просмотрщики медиа |
| `fonts` | Системные шрифты и Nerd Fonts |
| `games` | Игры, Wine и Steam с автонастройкой портов |
| `graphics` | Графика, 3D, CAD (FreeCAD, Darktable) |
| `hardware` | Инструменты диагностики оборудования |
| `math` | Математические приложения, Octave, GNU Radio |
| `messengers` | Мессенджеры (Telegram, Discord) |
| `multimedia` | Запись и трансляция экрана (OBS Studio) |
| `printing` | Печать и драйверы принтеров (CUPS, fxlinuxprint) |
| `sound` | Звук и управление воспроизведением (Pipewire, Playerctl) |
| `vpn` | VPN и прокси-клиенты (Amnezia, Clash Verge) |

Базовые CLI-пакеты находятся в `../modules/base/packages/base.nix`,
дополнительные утилиты и Alacritty — в `../modules/terminal/packages/`.
Настройки Nix и кэшей находятся в `../modules/base/configuration/`.

## Оконные менеджеры и окружения рабочего стола

Каждый компонент в `../modules/WM-DE/` подключается одной строкой в
`modules.nix` и экспортирует OS и Home части. Сейчас выбраны все четыре:

| Компонент | Содержимое |
| --- | --- |
| `hypr` | Hyprland, Grimblast и Lua-конфигурация |
| `niri` | Niri, iio-niri и конфигурация KDL |
| `drift` | DriftWM, патч overview, конфигурация, автоповорот и порталы WLR |
| `gnome` | GNOME и расширение поворота экрана |
| `common` | GDM, GTK-портал, ввод, графика, датчики, звук, питание, общие утилиты, DMS, тема, Waybar и WaylandKB |

OS и Home части каждого WM импортируют соответствующую часть `common` по
пути. Nix объединяет повторные импорты, поэтому общие настройки подключаются
один раз; отдельная строка для `common` в селекторе не нужна. У GNOME Home
часть пока содержит только этот общий импорт. Остальные компоненты находят
настройки в своих `configuration/`, `packages/` и `home_packages/` автоматически.

`packages/WMs.nix` удалён; импорт NixOS-модуля DriftWM находится внутри
`drift/configuration/driftwm.nix`, а импорт Home Manager-модуля DMS — внутри
`common/home_packages/dms/default.nix`. Патч overview остаётся рядом с
конфигурацией DriftWM и подключается по новому относительному пути.

Настройки Sunshine остаются в его отдельном компоненте. Для текущей
конфигурации Sunshine нужен выбранный `WM-DE/hypr`; его автологин и
виртуальный монитор сохранены. Параметры GDM сохранены. Настройки доверия к кэшу Hyprland находятся
в `base/configuration/caches.nix` вместе с остальными кэшами.

## База и дополнительные компоненты

`base` подключается первой строкой селектора и содержит базовую системную
инфраструктуру. В `packages/base.nix` собраны уже использовавшиеся `git`,
`wget`, `unzip`, `p7zip`, `fzf`, `bat`, `neovim`, `fastfetch`, `usbutils` и `zsh`.
Конфигурационные файлы включают NetworkManager, локаль и часовой пояс,
настройки Nix/nix-ld, Zsh, документацию, NH, SSH и клиентов бинарных кэшей.
Имя хоста, учётная запись, дополнительные порты, устройства и настройки
приложений остаются в основной конфигурации.

| Компонент | Назначение |
| --- | --- |
| `base` | Базовые пакеты и системная инфраструктура |
| `WM-DE/common/packages/networkmanager.nix` | Графический апплет NetworkManager поверх базы |
| `qbittorrent` | Опциональный клиент загрузок |
| `nix-serve` | Опциональный сервер собственного бинарного кэша |

qBittorrent и nix-serve по-прежнему выбраны в `modules.nix`; каждый можно
отключить удалением его строки. SSH и существующие правила для TCP/UDP 22
перенесены без изменений. Сервер nix-serve сохраняет прослушивание
`0.0.0.0:5000` и существующее открытие порта; он не входит в `base`.
Адреса кэшей и доверенные ключи сохранены, включая Hyprland.

Старый `configuration/nixpkgs.nix` удалён: в закреплённом nixpkgs отсутствует
QtWebEngine 5, поэтому разрешение `qtwebengine-5.15.19` больше не требуется.
OpenLDAP 2.6.13 уже исключает проблемные тесты синхронизации, включая i686;
локальное отключение всех его тестов убрано в пользу штатных настроек пакета.
Это проверено по исходникам и метаданным закреплённого nixpkgs, без сборок.
