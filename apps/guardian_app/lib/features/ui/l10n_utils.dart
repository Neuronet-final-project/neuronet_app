import 'package:flutter/material.dart';
import 'package:neuronet_core/neuronet_core.dart';

String translateError(BuildContext context, String? error) {
  if (error == null) return '';
  
  final l10n = context.localizations;
  
  if (error.startsWith('failedToRegisterAdolescent|')) {
    final details = error.split('|').last;
    return l10n.failedToRegisterAdolescent(details);
  }
  
  switch (error) {
    case 'pleaseFillRequiredFields':
      return l10n.pleaseFillRequiredFields;
    case 'pleaseEnterValidEmail':
      return l10n.pleaseEnterValidEmail;
    case 'unauthorizedGuardianAccess':
      return l10n.unauthorizedGuardianAccess;
    case 'unauthorizedRoleMismatch':
      return l10n.unauthorizedRoleMismatch;
    case 'nameCannotContainNumbers':
      return l10n.nameCannotContainNumbers;
    default:
      return error;
  }
}

String translateAlertSeverity(BuildContext context, String severity) {
  final l10n = context.localizations;
  final s = severity.toLowerCase();
  if (s.contains('high')) return l10n.highRisk;
  if (s.contains('medium')) return l10n.mediumRisk;
  return l10n.lowRisk;
}

String translateApprovalStatus(BuildContext context, String status) {
  final l10n = context.localizations;
  final s = status.toLowerCase();
  if (s.contains('approved')) return l10n.statusActive;
  if (s.contains('denied')) return l10n.statusSuspended;
  return l10n.statusPendingActivation;
}
