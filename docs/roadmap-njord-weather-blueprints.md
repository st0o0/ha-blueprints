# Roadmap: ha-njord Weather Blueprints

Blueprint ideas leveraging the `ha-njord` custom integration (gRPC-based local
weather service) — per-model weather entities, multi-model consensus, weather
alert events, activity indices, energy sensors, and derived comfort/trend
sensors.

## Status

| # | Blueprint | Key Entities | Status |
|---|-----------|--------------|--------|
| 1 | Laundry Drying Advisor | `sensor.home_laundry_index`, `sensor.home_weather_trend` | Done |
| 2 | Rain Warning for Open Windows | `sensor.home_weather_trend` (precip_starts_in_hours), window sensors | Done |
| 3 | Adaptive Heating COP Optimizer | `sensor.home_cop_estimate` (`cop_optimal` attribute) | Idea |
| 4 | Universal Weather Alert Notifier | `event.home_weather_alert` (all types/severities/lifecycle states) | Done |
| 5 | Night Cooling Window Control | `sensor.home_night_cooling` | Done |
| 6 | Running/Cycling Weather Window Finder | `sensor.home_running_index`, `sensor.home_cycling_index` | Done |
| 7 | UV Protection Reminder | UV alert sensor, presence | Done |
| 8 | Irrigation Automation with Frost/Rain Guard | `sensor.home_irrigation_index`, weather alerts, `sensor.home_vpd` | Done |
| 9 | Comfort Ventilation Assistant | `sensor.home_ventilation_index`, `sensor.home_dewpoint_comfort` | Done |
| 10 | Inversion/Air Quality Ventilation Lock | `binary_sensor.home_inversion` | Done |
| 11 | Consensus Reliability Warning | `weather.home_consensus` (`agreement`, `spread`) | Done |

Dropped from earlier brainstorming (superseded or descoped):
- **Solar-Yield Device Control** — merged into future energy-focused blueprint set, not in this batch.
- **BBQ Weekend Planner** — descoped, low priority.
- **Frost Warning**, **Storm Safety Routine**, **Thunderstorm Safety Mode** — superseded by #4 Universal Weather Alert Notifier, which covers all alert types generically (including escalation/de-escalation/cleared lifecycle).

## Blueprint Details

### 1. Laundry Drying Advisor
- **Trigger:** Time trigger (e.g. 7:00) or state change on `sensor.home_laundry_index`
- **Conditions:** `laundry_index` ≥ threshold AND `precip_starts_in_hours` > min dry window
- **Actions:** Notification with index and dry-window length
- **Inputs:** `notify_target`, `min_index`, `check_time`, `min_dry_window_hours`

### 2. Rain Warning for Open Windows
- **Trigger:** State change on `sensor.home_weather_trend` (`precip_starts_in_hours` drops below threshold)
- **Conditions:** at least one window `binary_sensor` is `on`, `reliable_hours` ≥ minimum
- **Actions:** Push notification listing affected windows + countdown; optional auto-close for smart windows
- **Inputs:** `window_entities` (list), `notify_target`, `reliability_min`, `auto_close` (bool)

### 3. Adaptive Heating COP Optimizer
- **Trigger:** Daily time trigger (evening)
- **Conditions:** `sensor.home_cop_estimate` available
- **Actions:** Schedule heating boost around `cop_optimal` hours (attribute)
- **Inputs:** `climate_entity`, `boost_duration`, `min_cop`

### 4. Universal Weather Alert Notifier
- **Trigger:** `event.home_weather_alert` — all four event types (`alert_started`, `alert_escalated`, `alert_deescalated`, `alert_cleared`)
- **Conditions:** `type` in selected alert-type list (frost/heat/storm/heavy_rain/uv/fog/snow/pressure_drop/thunderstorm) AND `severity` ≥ minimum (for started/escalated)
- **Actions:** Choose block per event type with distinct notification tone/title; optional TTS on `severity=red`
- **Inputs:** `notify_target`, `alert_types` (multi-select, default all), `min_severity`, `notify_on_cleared` (bool, default false), `notify_on_deescalated` (bool, default false), `media_player` (optional), `critical_severity_for_tts` (default red)

### 5. Night Cooling Window Control
- **Trigger:** State change on `sensor.home_night_cooling` crossing threshold
- **Conditions:** time window 22:00–5:00, indoor temp > outdoor temp
- **Actions:** Notify or open window covers
- **Inputs:** `window_covers`, `indoor_temp_sensor`, `night_cooling_min`, `time_window`

### 6. Running/Cycling Weather Window Finder
- **Trigger:** Morning time trigger
- **Conditions:** `running_index`/`cycling_index` ≥ threshold within forecast horizon
- **Actions:** Notification with best time window, wind (Beaufort), wind chill
- **Inputs:** `activity_type`, `notify_target`, `min_index`, `forecast_hours`

### 7. UV Protection Reminder
- **Trigger:** State change on UV alert sensor / forecast attribute
- **Conditions:** UV index ≥ threshold AND person present
- **Actions:** Notification; optional trigger of `sensor.home_shading`
- **Inputs:** `notify_target`, `uv_threshold`, `shading_cover_entities` (optional)

### 8. Irrigation Automation with Frost/Rain Guard
- **Trigger:** Time trigger (irrigation schedule)
- **Conditions:** `irrigation_index` ≥ threshold AND no active frost/heavy_rain alert AND `vpd` within range
- **Actions:** Turn on irrigation switch for computed duration
- **Inputs:** `irrigation_switch`, `min_irrigation_index`, `vpd_max`, `base_duration_minutes`

### 9. Comfort Ventilation Assistant
- **Trigger:** State change on `ventilation_index` or `dewpoint_comfort`
- **Conditions:** `dewpoint_comfort` in [oppressive, humid] AND `ventilation_index` ≥ threshold
- **Actions:** Notify "ventilate now" or drive fan/window entities
- **Inputs:** `notify_target`, `fan_entities` (optional), `min_ventilation_index`

### 10. Inversion/Air Quality Ventilation Lock
- **Trigger:** State change on `binary_sensor.home_inversion` → on
- **Conditions:** optionally combined with `sensor.home_hdd` (heating season)
- **Actions:** Notify to avoid ventilation; switch ventilation system to recirculation
- **Inputs:** `notify_target`, `ventilation_entity`, `recirculation_service_call` (optional)

### 11. Consensus Reliability Warning
- **Trigger:** State change on `weather.home_consensus` `agreement` attribute dropping below threshold
- **Conditions:** `spread` ≥ threshold (high model disagreement)
- **Actions:** Notify with `available_models` list, recommend re-checking planned outdoor activities
- **Inputs:** `notify_target`, `agreement_min`, `spread_max`

## Next Steps

- [ ] Pick first blueprint to implement (candidate: #4 Universal Weather Alert Notifier — combines the most entities/events)
- [ ] Follow existing repo conventions from `notification_mobile-actions.yaml` for structure/validation
- [ ] Validate against `scripts/validate-blueprints.sh`
