# Next steps

- Backup / transfer to other device:
  - Use password
  - On import Merge data properly
- App store releease
  - Check and describe permissions. Can we reduce?
  - Do Pre app store checks (play store and app store)
  - Create description
- Add id's to all text fields for testing (this will make tests independen from system language)

Icon updated:
Drop new SVGs in src/assets/app_icons/, render them with rsvg-convert:

```
# Re-render V2 app icons

rsvg-convert -w 1024 -h 1024 src/assets/app_icons/vaccination_app_icon_v2_light.svg -o src/assets/app_icons/generated/icon_light.png
rsvg-convert -w 1024 -h 1024 src/assets/app_icons/vaccination_app_icon_v2_dark.svg -o src/assets/app_icons/generated/icon_dark.png

# Re-render foreground-only logo marks (used for splash + in-app)

rsvg-convert -w 512 -h 512 src/assets/app_icons/vaccination_app_logo_light.svg -o src/assets/app_icons/generated/logo_foreground_light.png
rsvg-convert -w 512 -h 512 src/assets/app_icons/vaccination_app_logo_dark.svg -o src/assets/app_icons/generated/logo_foreground_dark.png
```

then re-run both

```
dart run flutter_launcher_icons
```

and

```
dart run flutter_native_splash:create
```
