-- Example ~/.hammerspoon/machine.lua. Copy it into place and edit the checks.
--
-- Each check:
--   name     label shown in the menu
--   cmd      run with /bin/sh -c. Exit 0 means OK; anything else means failed.
--            The first line it prints (stdout, else stderr) is shown next to
--            the name, so print something useful in both cases.
--   every    seconds between runs
--   timeout  seconds before a run is killed and counted as failed
--
-- `every` and `timeout` fall back to `defaults` below, then to 30s and 10s.
return {
  -- Optional: timing for every check on this machine that doesn't set its own.
  defaults = { every = 60, timeout = 10 },

  checks = {
    -- SSH tunnel: `ssh -L` listens as soon as it starts and keeps listening on
    -- a dead connection, so check that the service behind it answers, not
    -- just that the port is open.
    {
      name = "Tunnel",
      cmd = [[
        nc -z -G 2 localhost 8080 || { echo "tunnel down: localhost:8080 closed"; exit 1; }
        curl -fsS -m 3 -o /dev/null http://localhost:8080/ \
          || { echo "tunnel open, but the service is not answering"; exit 1; }
        echo "tunnel OK"
      ]],
      timeout = 8,
    },

    -- HTTP check. For anything longer, point cmd at a script instead.
    {
      name = "Example site",
      cmd = [[curl -fsS -m 5 -o /dev/null -w "HTTP %{http_code}" https://example.com]],
      every = 300, -- the answer only changes slowly
      timeout = 6,
    },
  },
}
