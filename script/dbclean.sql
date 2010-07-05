delete from projects where created_at < now() - interval '1 day';
