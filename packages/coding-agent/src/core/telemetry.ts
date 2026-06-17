import { FORK_CONFIG } from "./fork-config.ts";
import type { SettingsManager } from "./settings-manager.ts";

function isTruthyEnvFlag(value: string | undefined): boolean {
	if (!value) return false;
	return value === "1" || value.toLowerCase() === "true" || value.toLowerCase() === "yes";
}

export function isInstallTelemetryEnabled(
	settingsManager: SettingsManager,
	telemetryEnv: string | undefined = process.env.PI_TELEMETRY,
): boolean {
	if (FORK_CONFIG.disableTelemetry) {
		return false;
	}
	return telemetryEnv !== undefined ? isTruthyEnvFlag(telemetryEnv) : settingsManager.getEnableInstallTelemetry();
}

export function isAnalyticsEnabled(settingsManager: SettingsManager): boolean {
	if (FORK_CONFIG.disableTelemetry) {
		return false;
	}
	return settingsManager.getEnableAnalytics();
}
