export const PaymentStatus: {
    readonly AUTHORIZED:  'AUTHORIZED';
    readonly CAPTURED:    'CAPTURED';
    readonly AUTH_FAILED: 'AUTH_FAILED';
    readonly FAILED:      'FAILED';
    readonly VOIDED:      'VOIDED';
    readonly EXPIRED:     'EXPIRED';
    readonly CANCELLED:   'CANCELLED';
};
export type PaymentStatusValue = typeof PaymentStatus[keyof typeof PaymentStatus];

export interface ConfigureOptions {
    apiBaseUrl: string;
    checkoutUrl?: string;
    pollIntervalMs?: number;
    dismissible?: boolean;
}

export interface PaymentResult {
    sessionId: string;
    status: PaymentStatusValue;
    acquirer?: string | null;
    gatewayReference?: string | null;
    amount?: string | null;
    currency?: string | null;
    failureReason?: string | null;
}

declare class _Payvizio {
    configure(options: ConfigureOptions): Promise<void>;
    prefetch(): Promise<void>;
    checkout(sessionId: string): Promise<PaymentResult>;
    launchUpiIntent(intentUrl: string): Promise<boolean>;
}

export const Payvizio: _Payvizio;
