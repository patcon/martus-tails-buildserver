# Martus Desktop on Tails OS

## Two approaches

- **CB.** Custom Tails build
- **PV.** Use persistent volume (approach favored by this project)

## Compare and contrast over phases:

1. Original creation & distribution
2. Regular usage
3. Updating

#### Phase 1: Creation

- **CB** uses vagrant box on build system to generate ISO, which is then written directly to a USB via `dd`. Assuming persistent volumes needed, then boot that non-persistence USB and create remaining USB's through wizard so that they can have persistence once distributed.

* Could possibly disable flag that prevents first USB from having persistence, but perhaps bad practice? Doesn't seem possible: https://tails.boum.org/doc/first_steps/persistence/index.en.html

- **PV** involves creating a Tails USB via the regular process, then booting it in order to create a master Tails USB with persistence. That master is then booted, and its persistent vol configured to boot via dotfiles. These contents are available as a tarball, prepared once per Martus update, checksummed and optionally signed. Now that working USB with persistence is done, admin can copy the whole USB (Tails + persistence volume) many times on a build system with `dd`. Password on distributed USB's will be the same default one.

- Persistence:            manual config vs pre-configured
- Password on first boot: none          vs preset
- Password uniqueness:    yes           vs yes if changed

#### Phase 2: Usage

- **CB** involves booting the USB, and application is ready to go. For persistence, will need to configure persistent volume and restart. Password will then be needed to retrieve saved state, and will all be unique.

- **PV** will require the default password to be entered during boot, and the application is ready to go. Persistence is already available. For added security, user can be provided instructions to change default password via Disk Utility.

#### Phase 3: Update

- **CB** will need to have Tails' native auto-update disabled, as any update would override the custom image with regular tails. Tails updates would need to be re-built and re-distributed from Benetech. Users not able to self-update. New copies will need to be built for both Tails updates and Martus updates.

* Could perhaps host our own infra for signed updates and re-tool auto-updater to auto-update with our custom images? (lots of work)

- **PV** will work with native tails update, as the Tails partition is stock. Users will be prompted to auto-update as soon as Tails releases. Once one person updates, they can use the Tails installer to update the USB drives of coworkers. The installer was designed to preserve the persistent vol during update. It will save all users from having to download manually, as only one person will need to download the 200MB ISO via auto-updater. Distribution of updated USB's from Benetech will only be required for actual Martus updates, not Tails.

## Investigate

- Easy way for regular users to clone new USB's:
https://tails.boum.org/blueprint/backups/#index5h2
