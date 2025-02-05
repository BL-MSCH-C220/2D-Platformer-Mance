extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -500.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = 0

var damage = 10


func change_animation(a):
	if $Sprite.animation == a or ($Sprite.is_playing() and not $Sprite.sprite_frames.get_animation_loop($Sprite.animation)):
		return
	$Sprite.play(a)
	

func attack():
	var attack_rc = null
	if direction >= 0:
		attack_rc = $Attack_Right
	if direction < 0:
		attack_rc = $Attack_Left
	var enemy = attack_rc.get_collider()
	if enemy != null and enemy.has_method("damage"):
		enemy.damage(damage)
		

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		$Sprite.animation = "Fall"
	elif abs(velocity.x) > 0:
		change_animation("Walk")
	else:
		change_animation("Idle")

	# Handle Jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		change_animation("Jump")
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("Attack") and is_on_floor():
		change_animation("Attack")
		$Attack.start()


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED
		if direction < 0:
			$Sprite.flip_h = true
		else:
			$Sprite.flip_h = false
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
		
	move_and_slide()


func _on_coin_collector_body_entered(body):
	if body.name == "$Coins":
		body.get_coin(global_position)


func _on_attack_timeout():
	attack()
