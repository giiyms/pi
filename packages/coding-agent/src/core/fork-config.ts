/**
 * giiyms/pi fork behavior — source checkout, not an npm distribution.
 *
 * Central place for customizations that differ from upstream earendil-works/pi.
 */
export const FORK_CONFIG = {
	/** No pi.dev pings, install telemetry, analytics, or provider attribution headers. */
	disableTelemetry: true,
	/** No startup version check or "update available" banners. */
	disableUpdateChecks: true,
	/** No `pi update` (self or package npm updates). Use git + scripts/sync-upstream.sh. */
	disableSelfUpdate: true,
	/** No startup changelog or /changelog slash command. */
	disableChangelog: true,
	/** No /share (gist upload to pi.dev). */
	disableShare: true,
} as const;