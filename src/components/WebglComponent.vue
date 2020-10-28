<template>
  <div class="webgl-component" ref="container"></div>
</template>

<script lang="ts">
import { onMounted, ref } from 'vue'
import * as THREE from 'three'
import t1 from './picture.jpg'
import dat from 'dat.gui'

// eslint-disable-next-line
let OrbitControls = require('three-orbit-controls')(THREE)

export default {
  name: 'WebglComponent',
  setup() {
    const container = ref()
    let time = 0
    let camera, scene, renderer, geometry, material, mesh
    let positions, coordinates
    let textures
    let gui, settings

    const setSize = () => {
      const { width, height } = container.value.getBoundingClientRect()

      renderer.setSize(width, height)
    }

    const setCameraAspect = () => {
      const { width, height } = container.value.getBoundingClientRect()

      camera.aspect = width / height
      camera.updateProjectionMatrix()
    }

    const init = () => {
      settings = {
        progress: 0,
      }
      gui = new dat.GUI({ name: 'My GUI' })
      gui.add(settings, 'progress', 0, 300, 0.1).setValue(300)

      const { width, height } = container.value.getBoundingClientRect()

      camera = new THREE.PerspectiveCamera(70, width / height, 0.01, 10000)
      camera.position.z = 400

      scene = new THREE.Scene()

      textures = [new THREE.TextureLoader().load(t1)]

      // geometry = new THREE.PlaneBufferGeometry(1.0, 1.0, 10.0, 10.0)
      geometry = new THREE.BufferGeometry()

      const row = 512
      const col = 512

      positions = new THREE.BufferAttribute(new Float32Array(row * col * 3), 3)
      coordinates = new THREE.BufferAttribute(
        new Float32Array(row * col * 3),
        3
      )

      let index = 0
      for (let i = row / -2.0; i < row / 2; i++) {
        for (let j = col / -2.0; j < col / 2; j++) {
          positions.setXYZ(index, i, j, 0) // between -256 and 256
          coordinates.setXYZ(index, (i / 256.0 + 1) / 2, (j / 256 + 1) / 2, 0) // between 0 and 1
          index++
        }
      }

      geometry.setAttribute('position', positions)
      geometry.setAttribute('aCoordinates', coordinates)

      // material = new THREE.MeshNormalMaterial()
      material = new THREE.ShaderMaterial({
        fragmentShader: require('./fragment.glsl').default,
        vertexShader: require('./vertex.glsl').default,
        uniforms: {
          time: { value: 1.0 },
          t1: { value: textures[0] },
          progress: { value: null },
        },
        side: THREE.DoubleSide,
      })
      mesh = new THREE.Points(geometry, material)
      scene.add(mesh)

      renderer = new THREE.WebGLRenderer({ antialias: true })
      new OrbitControls(camera, renderer.domElement)

      setSize()
      container.value.appendChild(renderer.domElement)
    }

    const update = () => {
      // mesh.rotation.x += 0.005
      // mesh.rotation.y += 0.01

      renderer.render(scene, camera)

      window.requestAnimationFrame(update)

      time += 1
      material.uniforms.time.value = time
      material.uniforms.progress.value = settings.progress
    }

    const viewportHandler = () => {
      setSize()
      setCameraAspect()
    }

    onMounted(() => {
      init()
      update()

      window.addEventListener('resize', viewportHandler)
    })

    return {
      container,
    }
  },
}
</script>
