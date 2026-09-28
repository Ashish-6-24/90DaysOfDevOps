I
#!/bin/bash

with_local() {
local secret="Hidden inside function"
echo "Inside function: $secret"

}

without_local() {
leaked="Escaped the function!"

echo "Inside function: $leaked"

}

echo ""
with_local
echo "Outside function: $secret"
echo ""
without_local
echo "Outside function: $leaked"
