# doppelbot
Because I like designing 3d printers.

I made a deltabot, and it's really cool.  I can print really tall things.

But 3d prints are weakest in Z - printing really tall is maximizing the weak axis.

So instead of maximizing Z, I though about maximizing Y.  First concept here is the DoppelBot, which is a cube-shaped reprap that's easy to enclose, and has, by default, a one cubic foot build area. the print area of a standard reprap.  It accomplishes this 'twice as big' by the simple expedient of using two heated beds.

The basic design uses two lasercut endcaps, joined by OpenBuilds V-Rail.  The lasercut endcaps ensure that your rails are perfectly perpendicular and parallel - they don't even need to be cut to the exact correct length.  The machine itself uses a CoreXY gantry, and a Z bed with 3 independent leadscrews - so that the bed can truly level itself, none of this bed-level-compensation, if your bed is flat this machine will be able to tram it.

I'm experimenting with 9mm belts and over-built 3d printed carriages, to increase rigidity.

Also experimenting with a continous build system, wherein you can print dozens of objects in a row without human intervention.

[[/images/complete_machine.jpg|Doppelbot running its first print]]
