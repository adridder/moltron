# moltron

Self-evolving Agents. Grant your OpenClaw agents the skill to learn and improve skills autonomously.

## 🚀 Installation

### One-Line Install (Easiest)

Install directly from GitHub without cloning the repository:

```bash
curl -sSL https://raw.githubusercontent.com/adridder/moltron/main/install.sh | bash
```

Or using `wget`:

```bash
wget -qO- https://raw.githubusercontent.com/adridder/moltron/main/install.sh | bash
```

The script will automatically:
- 🌐 Download the latest version from GitHub
- ✅ Create `~/.openclaw/workspace/skills` if needed
- 📦 Install the moltron skill
- ✨ Display colorful progress messages
- 🔄 Handle existing installations (prompts before overwriting)

### Local Install (For Developers)

If you've already cloned the repository, run the installation script:

```bash
bash install.sh
```

### Manual Installation

If you prefer to install manually, copy the `moltron` folder to your OpenClaw skills directory:

```bash
cp -r moltron ~/.openclaw/workspace/skills/
```

### Verify Installation

After installation, the skill should be available at:
```
~/.openclaw/workspace/skills/moltron/
```

Restart your OpenClaw agent to load the new skill.

## 📖 Usage

Once installed, your OpenClaw agents will have access to self-evolving capabilities, allowing them to learn and improve skills autonomously.



