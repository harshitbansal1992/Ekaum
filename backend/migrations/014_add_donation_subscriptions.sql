-- Recurring donations: users can set up monthly/yearly donation subscriptions

CREATE TABLE IF NOT EXISTS donation_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL,
    frequency VARCHAR(20) NOT NULL DEFAULT 'monthly', -- monthly, yearly
    status VARCHAR(20) NOT NULL DEFAULT 'active', -- active, cancelled, paused
    razorpay_subscription_id VARCHAR(255),
    next_billing_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_donation_subscriptions_user_id ON donation_subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_donation_subscriptions_status ON donation_subscriptions(status);
