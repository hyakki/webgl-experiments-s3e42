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

import { EffectComposer } from 'three/examples/jsm/postprocessing/EffectComposer.js'
import { RenderPass } from 'three/examples/jsm/postprocessing/RenderPass.js'
import { UnrealBloomPass } from 'three/examples/jsm/postprocessing/UnrealBloomPass.js'

import glsl from 'glslify'

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
    let currentIndex, nextIndex
    let composer, renderPass, bloomPass

    const setSize = () => {
      const { width, height } = container.value.getBoundingClientRect()

      renderer.setPixelRatio(window.devicePixelRatio)

      renderer.setSize(width, height)
      composer.setSize(width, height)
    }

    const setCameraAspect = () => {
      const { width, height } = container.value.getBoundingClientRect()

      camera.aspect = width / height
      camera.updateProjectionMatrix()
    }

    const swapTexture = (currentIndex, nextIndex) => {
      material.uniforms.currentTexture.value = textures[currentIndex]
      material.uniforms.nextTexture.value = textures[nextIndex]
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
      gui.add(settings, 'uMix', 0, 1, 0.01)
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

      currentIndex = 0
      nextIndex = 1

      // material = new THREE.MeshNormalMaterial()
      material = new THREE.ShaderMaterial({
        fragmentShader: glsl(require('./glsl/fragment.glsl').default),
        vertexShader: glsl(require('./glsl/vertex.glsl').default),
        uniforms: {
          time: { value: 1.0 },
          currentTexture: { value: textures[currentIndex] },
          nextTexture: { value: textures[nextIndex] },
          uMix: { value: 0.0 },
          uProgress: { value: null },
          uBloom: { value: 0 },
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

      // scene.add(mesh2)

      renderer = new THREE.WebGLRenderer({ antialias: false, alpha: true })
      composer = new EffectComposer(renderer)

      renderPass = new RenderPass(scene, camera)

      bloomPass = new UnrealBloomPass(
        new THREE.Vector2(width, height),
        0.0,
        0.5,
        0.0
      )

      composer.addPass(renderPass)
      composer.addPass(bloomPass)

      bloomPass.renderToScreen = true

      // OrbitControls
      new OrbitControls(camera, renderer.domElement)

      setSize()
      container.value.appendChild(renderer.domElement)

      const o = {
        mix: 0,
        progress: 0,
      }

      const duration = 1.4

      const tl = gsap.timeline({
        delay: 2,
        paused: true,
        onUpdate: () => {
          settings.uMix = o.mix
          settings.uProgress = o.progress
          gui.updateDisplay()
        },
      })

      tl.to(
        o,
        {
          duration: duration / 2,
          progress: 100,
          ease: 'power4.easeIn',
        },
        '#start'
      )

      tl.to(
        bloomPass,
        {
          duration: duration / 2,
          strength: 0.5,
          ease: 'power4.easeIn',
        },
        '#start'
      )

      tl.to(
        o,
        {
          duration: duration * 1.5,
          mix: 1,
          ease: 'power4.easeOut',
        },
        `#start+=${duration * 0.2}`
      )

      tl.to(
        o,
        {
          duration: duration / 2,
          progress: 0,
          ease: 'power4.easeOut',
        },
        `#start+=${1.5 + duration * 0.75}`
      )

      tl.to(
        bloomPass,
        {
          duration: duration / 2,
          strength: 0,
          ease: 'power4.easeOut',
        },
        `#start+=${1.5 + duration * 0.75}`
      )

      tl.play()

      tl.eventCallback('onComplete', () => {
        currentIndex = nextIndex
        nextIndex = currentIndex > textures.length - 2 ? 0 : currentIndex + 1

        setTimeout(() => {
          settings.uMix = 0
          material.uniforms.uMix.value = 0
          swapTexture(currentIndex, nextIndex)

          tl.play(0)
        }, 3000)
      })
    }

    const update = () => {
      // mesh.rotation.x += 0.005
      // mesh.rotation.y += 0.01

      composer.render(scene, camera)

      raf = window.requestAnimationFrame(update)

      time += 1.0
      material.uniforms.time.value = time
      material.uniforms.uProgress.value = settings.uProgress
      material.uniforms.uMix.value = settings.uMix
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
