extends Area3D

@export var keep_particles_spawning = false
@export var particle_generator:GPUParticles2D
@export var particle_acceleration = Vector3.ZERO

func _ready():
	self.body_entered.connect(bodyEntered)

func bodyEntered(body):
	print("entered")
	if body.is_in_group("player"):
		particle_generator.emitting = keep_particles_spawning
		particle_generator.process_material.gravity = particle_acceleration
