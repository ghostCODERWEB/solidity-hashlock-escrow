export async function suite(h) {
  const token = await h.token();
  const c = await h.deploy("HashlockEscrow", [token.target, h.addresses[0]]);
  await h.tx(token.approve(c.target, 1000));
  const id = h.ethers.id("lock1");
  const secret = h.ethers.toUtf8Bytes("secret");
  const hash = h.ethers.sha256(secret);
  const now = await h.now();
  await h.tx(c.lock(id, h.addresses[1], 100, hash, now + 100));
  await h.test("wrong recipient rejected", () =>
    h.revert(() => c.connect(h.signers[2]).redeem(id, secret)),
  );
  await h.test("bad secret rejected", () =>
    h.revert(() => c.connect(h.signers[1]).redeem(id, "0x00")),
  );
  await h.test("early refund rejected", () => h.revert(() => c.refund(id)));
  await h.test("preimage releases escrow", async () => {
    await h.tx(c.connect(h.signers[1]).redeem(id, secret));
    h.eq(await token.balanceOf(h.addresses[1]), 100n);
    h.eq(await c.liability(), 0n);
  });
  await h.test("settled lock cannot replay", () =>
    h.revert(() => c.connect(h.signers[1]).redeem(id, secret)),
  );
  await h.test("expired lock refunds sender", async () => {
    const id2 = h.ethers.id("lock2");
    await h.tx(c.lock(id2, h.addresses[1], 50, hash, (await h.now()) + 10));
    await h.mine(11);
    await h.tx(c.refund(id2));
    h.eq(await c.liability(), 0n);
  });
}
