<template>
  <div class="webgl-component" ref="container"></div>
</template>

<script lang="ts">
import gsap from 'gsap'
import { onMounted, onUnmounted, ref } from 'vue'
import * as THREE from 'three'
import t1 from './textures/t1.jpg'
import t2 from './textures/t2.jpg'
import t3 from './textures/t3.jpg'
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
    let raf
    let mesh2

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
        uProgress: 0,
        uMix: 0,
        cameraZ: 126,
        wireframe: false,
      }
      gui = new dat.GUI({ name: 'My GUI' })
      gui.add(settings, 'uProgress', 0, 128, 0.1)
      gui.add(settings, 'uMix', 0, 3, 0.1)
      gui.add(settings, 'wireframe').onChange(() => {
        mesh2.material.wireframe = settings.wireframe
        mesh2.material.opacity = settings.wireframe ? 1.0 : 0.0
      })
      gui.add(settings, 'cameraZ', 0, 300, 1).onChange(() => {
        camera.position.z = settings.cameraZ
      })

      const { width, height } = container.value.getBoundingClientRect()

      camera = new THREE.PerspectiveCamera(70, width / height, 0.01, 10000)
      camera.position.z = settings.cameraZ

      camera.position.z = settings.cameraZ

      scene = new THREE.Scene()

      textures = [
        new THREE.TextureLoader().load(t1),
        new THREE.TextureLoader().load(t2),
        new THREE.TextureLoader().load(t3),
      ]

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
          positions.setXYZ(index, i, j, -256.0) // between -256 and 256
          coordinates.setXYZ(index, (i / 256.0 + 1) / 2, (j / 256 + 1) / 2, 0) // between 0 and 1
          index++
        }
      }

      geometry.setAttribute('position', positions)
      geometry.setAttribute('aCoordinates', coordinates)

      // material = new THREE.MeshNormalMaterial()
      material = new THREE.ShaderMaterial({
        fragmentShader: require('./glsl/fragment.glsl').default,
        vertexShader: require('./glsl/vertex.glsl').default,
        uniforms: {
          time: { value: 1.0 },
          currentTexture: { value: textures[0] },
          nextTexture: { value: textures[1] },
          uMix: { value: 0.0 },
          uProgress: { value: null },
        },
        side: THREE.DoubleSide,
        transparent: true,
      })
      mesh = new THREE.Points(geometry, material)
      scene.add(mesh)

      mesh2 = new THREE.Mesh(
        new THREE.BoxGeometry(512, 512, 512),
        new THREE.MeshBasicMaterial({
          opacity: 0.0,
          transparent: true,
          wireframe: settings.wireframe,
        })
      )

      scene.add(mesh2)

      renderer = new THREE.WebGLRenderer({ antialias: true })

      // OrbitControls
      new OrbitControls(camera, renderer.domElement)

      setSize()
      container.value.appendChild(renderer.domElement)

      const o = { v: 0 }

      gsap.to(o, {
        duration: 3 * 2,
        v: 3,
        repeat: -1,
        ease: 'linear',
        onUpdate: () => {
          settings.uMix = o.v
          gui.updateDisplay()
        },
      })
    }

    const isBetween = (v, min, max) => {
      return v >= min && v < max
    }

    const swapTexture = (currentIndex, nextIndex) => {
      material.uniforms.currentTexture.value = textures[currentIndex]
      material.uniforms.nextTexture.value = textures[nextIndex]
    }

    const update = () => {
      // mesh.rotation.x += 0.005
      // mesh.rotation.y += 0.01

      renderer.render(scene, camera)

      raf = window.requestAnimationFrame(update)

      time += 1.0
      material.uniforms.time.value = time
      material.uniforms.uProgress.value = settings.uProgress
      material.uniforms.uMix.value = settings.uMix

      if (isBetween(settings.uMix, 1.0, 2.0)) {
        swapTexture(1, 2)
      } else if (isBetween(settings.uMix, 2.0, 3.0)) {
        swapTexture(2, 0)
      } else {
        swapTexture(0, 1)
      }
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

    onUnmounted(() => {
      gui.destroy()
      window.cancelAnimationFrame(raf)
      window.removeEventListener('resize', viewportHandler)
    })

    return {
      container,
    }
  },
}
</script>
