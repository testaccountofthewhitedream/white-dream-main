SUBSYSTEM_DEF(icon_smooth)
	name = "Icon Smoothing"
	init_order = INIT_ORDER_ICON_SMOOTHING
	wait = 1
	priority = FIRE_PRIOTITY_SMOOTHING
	flags = SS_TICKER

	///Blueprints assemble an image of what pipes/manifolds/wires look like on initialization, and thus should be taken after everything's been smoothed
	var/list/blueprint_queue = list()
	var/list/smooth_queue = list()
	var/list/deferred = list()

/datum/controller/subsystem/icon_smooth/fire()
	var/list/cached = smooth_queue
	while(length(cached))
		var/atom/smoothing_atom = cached[length(cached)]
		cached.len--
		if(QDELETED(smoothing_atom) || !(smoothing_atom.smooth & SMOOTH_QUEUED))
			continue
		if(smoothing_atom.flags_1 & INITIALIZED_1)
			smooth_icon(smoothing_atom)
		else
			deferred += smoothing_atom
		if (MC_TICK_CHECK)
			return

	if (!cached.len)
		if (deferred.len)
			smooth_queue = deferred
			deferred = cached
		else
			can_fire = FALSE

/datum/controller/subsystem/icon_smooth/Initialize()
	smooth_zlevel(1,TRUE)
	smooth_zlevel(2,TRUE)

	var/list/queue = smooth_queue
	smooth_queue = list()

	while(length(queue))
		var/atom/smoothing_atom = queue[length(queue)]
		queue.len--
		if(QDELETED(smoothing_atom) || !(smoothing_atom.smooth & SMOOTH_QUEUED) || smoothing_atom.z <= 2)
			continue
		smooth_icon(smoothing_atom)
		CHECK_TICK

	queue = blueprint_queue
	blueprint_queue = list()

	for(var/item in queue)
		var/atom/movable/movable_item = item
		if(!isturf(movable_item.loc))
			continue
		var/turf/item_loc = movable_item.loc
		item_loc.add_blueprints(movable_item)

	SStitle.set_load_state("smoothing")

	return ..()


/datum/controller/subsystem/icon_smooth/proc/add_to_queue(atom/thing)
	if(thing.smooth & SMOOTH_QUEUED)
		return
	thing.smooth |= SMOOTH_QUEUED
	smooth_queue += thing
	if(!can_fire)
		can_fire = TRUE

/datum/controller/subsystem/icon_smooth/proc/remove_from_queues(atom/thing)
	thing.smooth &= ~SMOOTH_QUEUED
	smooth_queue -= thing
	blueprint_queue -= thing
	deferred -= thing
