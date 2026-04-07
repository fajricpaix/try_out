import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnergyService {
  EnergyService._();

  static const int defaultEnergy = 100;
  static const int simulationCost = 13;
  static const int adRewardEnergy = 10;
  static const int _regenIntervalMs = 13 * 60 * 1000;
  static const String _deviceEnergyKey = 'device_energy';
  static const String _deviceEnergyUpdatedAtMsKey =
      'device_energy_updated_at_ms';

  static final ValueNotifier<int> energyNotifier = ValueNotifier<int>(
    defaultEnergy,
  );

  static Map<String, int> _applyRegen({
    required int currentEnergy,
    required int lastUpdatedAtMs,
  }) {
    final int now = DateTime.now().millisecondsSinceEpoch;
    int normalizedEnergy = currentEnergy < 0 ? 0 : currentEnergy;
    int normalizedUpdatedAt = lastUpdatedAtMs <= 0 ? now : lastUpdatedAtMs;

    // Bonus energy from ads may exceed defaultEnergy and should not be reduced by regen logic.
    if (normalizedEnergy > defaultEnergy) {
      return {'energy': normalizedEnergy, 'updatedAtMs': normalizedUpdatedAt};
    }

    if (normalizedEnergy >= defaultEnergy) {
      return {'energy': defaultEnergy, 'updatedAtMs': normalizedUpdatedAt};
    }

    final int elapsed = now - normalizedUpdatedAt;
    if (elapsed < _regenIntervalMs) {
      return {'energy': normalizedEnergy, 'updatedAtMs': normalizedUpdatedAt};
    }

    final int regenSteps = elapsed ~/ _regenIntervalMs;
    if (regenSteps <= 0) {
      return {'energy': normalizedEnergy, 'updatedAtMs': normalizedUpdatedAt};
    }

    normalizedEnergy = (normalizedEnergy + regenSteps)
        .clamp(0, defaultEnergy)
        .toInt();

    if (normalizedEnergy >= defaultEnergy) {
      normalizedUpdatedAt = now;
    } else {
      normalizedUpdatedAt += regenSteps * _regenIntervalMs;
    }

    return {'energy': normalizedEnergy, 'updatedAtMs': normalizedUpdatedAt};
  }

  static Future<Map<String, int>> _readEnergyState(User? user) async {
    final prefs = await SharedPreferences.getInstance();
    final int currentEnergy = prefs.getInt(_deviceEnergyKey) ?? defaultEnergy;
    final int updatedAtMs =
        prefs.getInt(_deviceEnergyUpdatedAtMsKey) ??
        DateTime.now().millisecondsSinceEpoch;

    final regenState = _applyRegen(
      currentEnergy: currentEnergy,
      lastUpdatedAtMs: updatedAtMs,
    );

    if (regenState['energy'] != currentEnergy ||
        regenState['updatedAtMs'] != updatedAtMs) {
      await Future.wait([
        prefs.setInt(_deviceEnergyKey, regenState['energy']!),
        prefs.setInt(_deviceEnergyUpdatedAtMsKey, regenState['updatedAtMs']!),
      ]);
    }

    return regenState;
  }

  static Future<int> _readEnergy(User? user) async {
    final regenState = await _readEnergyState(user);
    return regenState['energy']!;
  }

  static Future<Duration?> getTimeUntilNextRegen(User? user) async {
    final state = await _readEnergyState(user);
    final int energy = state['energy']!;
    if (energy >= defaultEnergy) {
      return null;
    }

    final int updatedAtMs = state['updatedAtMs']!;
    final int now = DateTime.now().millisecondsSinceEpoch;
    final int elapsed = (now - updatedAtMs).clamp(0, _regenIntervalMs).toInt();
    final int remainingMs = (_regenIntervalMs - elapsed)
        .clamp(0, _regenIntervalMs)
        .toInt();
    return Duration(milliseconds: remainingMs);
  }

  static Future<void> _writeEnergy(User? user, int energy) async {
    final int normalized = energy < 0 ? 0 : energy;
    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setInt(_deviceEnergyKey, normalized),
      prefs.setInt(_deviceEnergyUpdatedAtMsKey, nowMs),
    ]);
    energyNotifier.value = normalized;
  }

  static Future<int> getCurrentEnergy(User? user) async {
    final int energy = await _readEnergy(user);
    energyNotifier.value = energy;
    return energy;
  }

  static Future<void> syncEnergyForUser(User? user) async {
    final int energy = await _readEnergy(user);
    energyNotifier.value = energy;
  }

  static Future<bool> consumeSimulationEnergy(User? user) async {
    final int current = await _readEnergy(user);
    if (current < simulationCost) {
      energyNotifier.value = current;
      return false;
    }

    final int next = current - simulationCost;
    await _writeEnergy(user, next);
    return true;
  }

  static Future<int> addEnergyFromAd(
    User? user, {
    int amount = adRewardEnergy,
  }) async {
    final int current = await _readEnergy(user);
    int next = current + (amount < 0 ? 0 : amount);
    if (user == null) {
      next = next.clamp(0, defaultEnergy).toInt();
    }
    await _writeEnergy(user, next);
    return next;
  }
}
