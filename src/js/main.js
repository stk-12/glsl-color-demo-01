import '../css/style.scss'
import * as THREE from "three";
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls.js";
import GUI from "lil-gui";
import vertexSource from "./shader/vertexShader.glsl";
import fragmentSource from "./shader/fragmentShader.glsl";

import palettes from 'nice-color-palettes';

class Main {
  constructor() {
    this.viewport = {
      width: window.innerWidth,
      height: window.innerHeight
    };

    this.canvas = document.querySelector("#canvas");
    this.renderer = null;
    this.scene = new THREE.Scene();
    this.camera = null;
    this.cameraFov = 45;
    this.cameraFovRadian = (this.cameraFov / 2) * (Math.PI / 180);
    this.cameraDistance = (this.viewport.height / 2) / Math.tan(this.cameraFovRadian);
    this.controls = null;
    this.gui = new GUI();
    this.geometry = null;
    this.cubeGeometry = null;
    this.material = null;
    this.mesh = null;
    this.cubeMesh = null;

    this.indexPallets = 2;
    this.pallets = null;
    this._setPallets(this.indexPallets);

    this.uniforms = {
      uTime: {
        value: 0.0
      },
      uTimeSpeed: {
        value: 0.5
      },
      uResolution: {
        value: new THREE.Vector2(this.viewport.width, this.viewport.height)
      },
      uTexResolution: {
        value: new THREE.Vector2(2048, 1024)
      },
      uNoiseLoudness: {
        value: new THREE.Vector2(1.0, 1.0)
      },
      uGrainScale: {
        value: 0.3
      },
      uGrainStrong: {
        value: 0.1
      },
      uColor1: {
        value: this.pallets[0]
      },
      uColor2: {
        value: this.pallets[1]
      },
      uColor3: {
        value: this.pallets[2]
      },
      uColor4: {
        value: this.pallets[3]
      }
    };

    this.clock = new THREE.Clock();

    this.init();
  }

  _setRenderer() {
    this.renderer = new THREE.WebGLRenderer({
      canvas: this.canvas,
      alpha: true
    });
    this.renderer.setPixelRatio(window.devicePixelRatio);
    this.renderer.setSize(this.viewport.width, this.viewport.height);
  }

  _setCamera() {

    //??????????????????WebGL????????????????????????
    this.camera = new THREE.PerspectiveCamera(this.cameraFov, this.viewport.width / this.viewport.height, 1, this.cameraDistance * 2);
    this.camera.position.z = this.cameraDistance;
    this.camera.lookAt(new THREE.Vector3(0, 0, 0));
    this.scene.add(this.camera);
  }

  _setPallets(index) {
    this.pallets = palettes[index].map((color) => new THREE.Color(color));
    
  }

  _setGui() {
    const colorGuiObj = {
      changeColor: ()=> {
        this.indexPallets = Math.floor(Math.random() * 100);
        this._setPallets(this.indexPallets);
        this.uniforms.uColor1.value = this.pallets[0];
        this.uniforms.uColor2.value = this.pallets[1];
        this.uniforms.uColor3.value = this.pallets[2];
        this.uniforms.uColor4.value = this.pallets[3];
      }
    }

    this.gui.add(this.uniforms.uNoiseLoudness.value, 'x').min(0.0).max(100.0).step(0.2).name('????????? X???')
    this.gui.add(this.uniforms.uNoiseLoudness.value, 'y').min(0.0).max(100.0).step(0.2).name('????????? Y???')
    this.gui.add(this.uniforms.uGrainScale, 'value').min(0.0).max(1.0).step(0.01).name('??????????????? ?????????')
    this.gui.add(this.uniforms.uGrainStrong, 'value').min(0.0).max(1.0).step(0.01).name('??????????????? ??????')
    this.gui.add(this.uniforms.uTimeSpeed, 'value').min(0.001).max(5.0).step(0.001).name('????????????')
    this.gui.addColor(this.uniforms.uColor1, 'value').name('????????? 1').listen()
    this.gui.addColor(this.uniforms.uColor2, 'value').name('????????? 2').listen()
    this.gui.addColor(this.uniforms.uColor3, 'value').name('????????? 3').listen()
    this.gui.addColor(this.uniforms.uColor4, 'value').name('????????? 4').listen()
    this.gui.add(colorGuiObj, 'changeColor').name('???????????????').listen()

    
  }

  _setControlls() {
    this.controls = new OrbitControls(this.camera, this.canvas);
    this.controls.enableDamping = true;
  }

  _setLight() {
    const light = new THREE.DirectionalLight(0xffffff, 1.5);
    light.position.set(1, 1, 1);
    this.scene.add(light);
  }

  _addMesh() {
    //???????????????
    this.geometry = new THREE.PlaneGeometry(this.viewport.width, this.viewport.height, 40, 40);
    this.cubeGeometry = new THREE.SphereGeometry(200, 40, 40);

    //???????????????
    this.material = new THREE.ShaderMaterial({
      uniforms: this.uniforms,
      vertexShader: vertexSource,
      fragmentShader: fragmentSource,
      side: THREE.DoubleSide
    });

    //????????????
    this.mesh = new THREE.Mesh(this.geometry, this.material);
    this.scene.add(this.mesh);

    this.cubeMesh = new THREE.Mesh(this.cubeGeometry, this.material);
    this.cubeMesh.position.z += 300;
  }

  init() {
    this._setRenderer();
    this._setCamera();
    this._setGui();
    this._setControlls();
    this._setLight();
    this._addMesh();

    this._update();
    this._addEvent();
  }

  _update() {

    const elapsedTime = this.clock.getElapsedTime();
    this.uniforms.uTime.value = elapsedTime * 0.5;

    //??????????????????
    this.renderer.render(this.scene, this.camera);
    this.controls.update();
    requestAnimationFrame(this._update.bind(this));
  }

  _onResize() {
    this.viewport = {
      width: window.innerWidth,
      height: window.innerHeight
    }
    // ????????????????????????????????????
    this.renderer.setSize(this.viewport.width, this.viewport.height);
    // ???????????????????????????????????????
    this.camera.aspect = this.viewport.width / this.viewport.height;
    this.camera.updateProjectionMatrix();
    // ???????????????????????????
    this.cameraDistance = (this.viewport.height / 2) / Math.tan(this.cameraFovRadian); //?????????????????????????????????????????????
    this.camera.position.z = this.cameraDistance;
    // uniforms???????????????
    this.mesh.material.uniforms.uResolution.value.set(this.viewport.width, this.viewport.height);
    // mesh???scale??????
    const scaleX = Math.round(this.viewport.width / this.mesh.geometry.parameters.width * 100) / 100 + 0.01;
    const scaleY = Math.round(this.viewport.height / this.mesh.geometry.parameters.height * 100) / 100 + 0.01;
    this.mesh.scale.set(scaleX, scaleY, 1);
  }

  _addEvent() {
    window.addEventListener("resize", this._onResize.bind(this));
  }
}

const main = new Main();
